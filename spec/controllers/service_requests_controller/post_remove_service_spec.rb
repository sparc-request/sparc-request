require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe 'POST remove_service' do

    before do
      session[:identity_id] = jug2.id
    end

    before(:each) do
      allow(controller.request).to receive(:referrer).and_return('http://example.com')
    end

    let!(:core2) { create(:core, parent_id: program.id) }

    let!(:service1) { service = create( :service, organization_id: core.id) }
    let!(:service2) { service = create( :service, organization_id: core.id) }
    let!(:service3) { service = create( :service, organization_id: core2.id) }
    
    let!(:ssr1) { create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
    let!(:ssr2) { create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }

    let!(:line_item1) { create(:line_item, service_id: service1.id, service_request_id: service_request.id, sub_service_request_id: ssr1.id) }
    let!(:line_item2) { create(:line_item, service_id: service2.id, service_request_id: service_request.id, sub_service_request_id: ssr1.id) }
    let!(:line_item3) { create(:line_item, service_id: service3.id, service_request_id: service_request.id, sub_service_request_id: ssr2.id) }


    it 'should mark LineItems of related Services of Service as optional' do
      # make service2 a related Service of service1,
      # so expect service2's LineItem to be optional
      create(:service_relation, service: service1, related_service: service2)
      line_item2.update_attributes(optional: false)

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      expect(line_item2.reload.optional).to eq(true)
    end

    it 'should delete any LineItems for the removed Service' do
      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(service_request.line_items).not_to include(line_item1)
      expect(service_request.line_items).to include(line_item2)
      expect(service_request.line_items).to include(line_item3)
    end

    it "should destroy each Arm of Protocol's only if ServiceRequest has no Services" do
      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(Arm.count).to eq 2

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service2.id,
        :line_item_id  => line_item2.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(Arm.count).to eq 2

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service3.id,
        :line_item_id  => line_item3.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(Arm.count).to eq 0
    end

    it 'should delete SubServiceRequests for Organizations that no longer have a Service in the ServiceRequest' do
      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(service_request.sub_service_requests).to include(ssr1)
      expect(service_request.sub_service_requests).to include(ssr2)

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service2.id,
        :line_item_id  => line_item2.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(service_request.sub_service_requests).not_to include(ssr1)
      expect(service_request.sub_service_requests).to include(ssr2)

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service3.id,
        :line_item_id  => line_item3.id,
        :format        => :js,
      }.with_indifferent_access

      service_request.reload
      expect(service_request.sub_service_requests).not_to include(ssr1)
      expect(service_request.sub_service_requests).not_to include(ssr2)
    end

    it 'should set @page' do
      allow(controller.request).to receive(:referrer).and_return('http://example.com/foo/bar')

      session[:service_request_id] = service_request.id
      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      expect(assigns(:page)).to eq 'bar'
    end

    it 'should raise an exception if a Service is removed twice' do
      session[:service_request_id] = service_request.id

      post :remove_service, {
        :id            => service_request.id,
        :service_id    => service1.id,
        :line_item_id  => line_item1.id,
        :format        => :js,
      }.with_indifferent_access

      expect {
        post :remove_service, {
          :id            => service_request.id,
          :service_id    => service1.id,
          :line_item_id  => line_item1.id,
          :format        => :js,
        }.with_indifferent_access
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'ServiceRequest not in draft or first_draft and has been submitted' do

      before(:each) { service_request.update_attribute(:status, 'not_draft') }

      context 'removed SubServiceRequest created before submit time' do

        it 'should send notifications to the service provider' do
          service_request.update_attribute(:submitted_at, Time.zone.now)
          ssr2.update_attribute(:created_at, Time.zone.now.ago(60))

          expect(controller).to receive(:send_ssr_service_provider_notifications)
          post :remove_service, {
                 :id            => service_request.id,
                 :service_id    => service3.id,
                 :line_item_id  => line_item3.id,
                 :format        => :js,
               }.with_indifferent_access
        end
      end

      context 'removed SubServiceRequest created after submit time' do

        it 'should not send notifications to the service provider' do
          service_request.update_attribute(:submitted_at, Time.zone.now.ago(60))
          ssr2.update_attribute(:created_at, Time.zone.now)

          expect(controller).to_not receive(:send_ssr_service_provider_notifications)
          post :remove_service, {
                 :id            => service_request.id,
                 :service_id    => service1.id,
                 :line_item_id  => line_item1.id,
                 :format        => :js,
               }.with_indifferent_access
        end
      end
    end

    context 'SubServiceRequest not specified' do

      it 'should set @line_items to the ServiceRequest LineItems' do
        post :remove_service, {
               :id            => service_request.id,
               :service_id    => service1.id,
               :line_item_id  => line_item1.id,
               :format        => :js,
             }.with_indifferent_access

        expect(assigns(:line_items)).to eq(service_request.reload.line_items)
      end
    end

    context 'SubServiceRequest specified' do

      before(:each) { session[:sub_service_request_id] = ssr1.id }

      it 'should set @line_items to the SubServiceRequest LineItems' do
        line_item1.update_attributes(sub_service_request_id: ssr1.id)
        line_item2.update_attributes(sub_service_request_id: ssr1.id)
        post :remove_service, {
               :id            => service_request.id,
               :service_id    => service1.id,
               :line_item_id  => line_item1.id,
               :format        => :js,
             }.with_indifferent_access
        expect(assigns(:line_items)).to eq(ssr1.reload.line_items)
      end
    end
  end
end
