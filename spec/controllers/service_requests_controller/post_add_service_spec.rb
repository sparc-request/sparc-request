require 'rails_helper'

RSpec.describe ServiceRequestsController do

  describe 'POST add_service' do

    stub_controller

    let_there_be_lane
    let_there_be_j
    build_service_request_with_study
    build_one_time_fee_services
    build_per_patient_per_visit_services
    let!(:core2) { create(:core, parent_id: program.id) }

    let!(:new_service) do
      service = create(:service,
                       pricing_map_count: 1,
                       one_time_fee: true,
                       organization_id: core.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today,
                                                quantity_minimum: 42)
      service
    end

    let!(:new_service2) do
      service = create(:service,
                       pricing_map_count: 1,
                       one_time_fee: true,
                       organization_id: core.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today,
                                                quantity_minimum: 54)
      service
    end

    let!(:new_service3) do
      service = create(:service,
                       pricing_map_count: 1,
                       organization_id: core2.id)
      service.pricing_maps[0].update_attributes(display_date: Date.today)
      service
    end

    before do
      session[:identity_id] = jug2.id
    end

    it 'should accept params[:service_id] prefixed with "service-"' do
      post :add_service, { id: service_request.id, service_id: "service-#{new_service.id}", format: :js }
      expect(response.status).to eq 200
    end

    it 'should give an error if the ServiceRequest already has a LineItem for the Service' do
      create(:line_item,
             service_id: new_service.id,
             service_request_id: service_request.id)

      post :add_service, {
             :id          => service_request.id,
             :service_id  => new_service.id,
             :format      => :js
           }.with_indifferent_access
      expect(response.body).to eq 'Service exists in line items'
    end

    it 'should create a LineItem for the Service' do
      orig_count = service_request.line_items.count

      post :add_service, {
             :id          => service_request.id,
             :service_id  => new_service.id,
             :format      => :js
           }.with_indifferent_access

      service_request.reload

      expect(service_request.line_items.count).to eq orig_count + 1
      line_item = assigns(:new_line_items).first
      expect(line_item.service).to eq new_service
      expect(line_item.optional).to eq true
      expect(line_item.quantity).to eq 42
    end

    it 'should create a LineItem for a required service' do
      orig_count = service_request.line_items.count

      create(:service_relation,
             service_id: new_service.id,
             related_service_id: new_service2.id,
             optional: false)

      post :add_service, { id: service_request.id, service_id: new_service.id, format: :js }.with_indifferent_access

      # there was one service and one LineItem already, then we added
      # one

      service_request.reload
      expect(service_request.line_items.count).to eq orig_count + 2
      line_item = service_request.line_items.find_by_service_id(new_service2.id)
      expect(line_item.service).to eq new_service2
      expect(line_item.optional).to eq false
      expect(line_item.quantity).to eq 54
    end

    it 'should create a LineItem for an optional Service' do
      orig_count = service_request.line_items.count

      create(:service_relation,
             service_id: new_service.id,
             related_service_id: new_service2.id,
             optional: true)

      post :add_service, {
             :id          => service_request.id,
             :service_id  => new_service.id,
             :format      => :js
           }.with_indifferent_access

      service_request.reload
      expect(service_request.line_items.count).to eq orig_count + 2

      line_item = service_request.line_items.find_by_service_id(new_service.id)
      expect(line_item.service).to eq new_service
      expect(line_item.optional).to eq true
      expect(line_item.quantity).to eq 42

      line_item = service_request.line_items.find_by_service_id(new_service2.id)
      expect(line_item.service).to eq new_service2
      expect(line_item.optional).to eq true
      expect(line_item.quantity).to eq 54
    end

    it 'should create a SubServiceRequest for each organization in the service list' do
      orig_count = service_request.sub_service_requests.count

      [ new_service, new_service2, new_service3 ].each do |service_to_add|
        post :add_service, {
               :id          => service_request.id,
               :service_id  => service_to_add.id,
               :format      => :js
             }.with_indifferent_access
      end

      service_request.reload
      expect(service_request.sub_service_requests.count).to eq orig_count + 2
      expect(service_request.sub_service_requests[-2].organization).to eq core
      expect(service_request.sub_service_requests[-1].organization).to eq core2
    end

    it 'should update each of the LineItems with the appropriate ssr id' do
      orig_count = service_request.line_items.count

      [ new_service, new_service2, new_service3 ].each do |service_to_add|
        post :add_service, {
               :id          => service_request.id,
               :service_id  => service_to_add.id,
               :format      => :js
             }.with_indifferent_access
      end

      core_ssr = service_request.sub_service_requests.find_by_organization_id(core.id)
      core2_ssr = service_request.sub_service_requests.find_by_organization_id(core2.id)

      service_request.reload
      expect(service_request.line_items.count).to eq(orig_count + 3)
      expect(service_request.line_items[-3].sub_service_request).to eq core_ssr
      expect(service_request.line_items[-2].sub_service_request).to eq core_ssr
      expect(service_request.line_items[-1].sub_service_request).to eq core2_ssr
    end
  end
end
