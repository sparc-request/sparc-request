require 'spec_helper'

describe Portal::ServiceRequestsController do
  stub_portal_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:study) { study = Study.create(FactoryGirl.attributes_for(:protocol)); study.save!(:validate => false); study }

  # TODO: assign service_list

  let!(:service_request) {
    FactoryGirl.create(
      :service_request,
      visit_count: 0,
      subject_count: 1,
      protocol_id: study.id)
  }

  let!(:ssr) {
    FactoryGirl.create(
        :sub_service_request,
        service_request_id: service_request.id,
        organization_id: core.id)
  }

  let!(:subsidy) {
    FactoryGirl.create(
        :subsidy,
        sub_service_request_id: ssr.id)
  }

  let!(:service) {
    service = FactoryGirl.create(
        :service,
        organization: core,
        pricing_map_count: 1)
    service.pricing_maps[0].display_date = Date.today
    service
  }

  let!(:line_item) { FactoryGirl.create(:line_item, service_id: service.id, service_request_id: service_request.id) }

  describe 'GET show' do
    it 'should set instance variables' do
      session[:service_calendar_page] = 1
      get :show, {
        format: :js,
        id: service_request.id,
      }.with_indifferent_access

      service_request.reload

      assigns(:service_request).should eq service_request

      # Not using assigns() here since it calls with_indifferent_access
      controller.instance_eval { @service_list }.should eq service_request.service_list

      assigns(:protocol).should eq study
      assigns(:page).should eq 1
      assigns(:tab).should eq 'pricing'
    end
  end

  describe 'POST add_per_patient_per_visit_visit' do
    it 'should set instance variables' do
      post :add_per_patient_per_visit_visit, {
        format: :js,
        id: service_request.id,
        service_request_id: service_request.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access

      assigns(:sub_service_request).should eq ssr
      assigns(:subsidy).should eq subsidy
      assigns(:candidate_per_patient_per_visit).should eq [ service ]
      assigns(:service_request).should eq service_request
    end

    # TODO: test candidate_per_patient_per_visit

    it 'should add a visit' do
      post :add_per_patient_per_visit_visit, {
        format: :js,
        id: service_request.id,
        service_request_id: service_request.id,
        sub_service_request_id: ssr.id,
      }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 1
    end

    # TODO: test visit_position

    it 'should call fix_pi_contribution on the subsidy' do
      # TODO
    end

    it 'should create toasts for each of the new visits created' do
      # TODO
    end
  end

  describe 'POST remove_per_patient_per_visit_visit' do
    before(:each) do
      service_request.update_attributes(visit_count: 10)
      Visit.bulk_create(10, line_item_id: line_item.id)
    end

    it 'should set instance variables' do
      post :remove_per_patient_per_visit_visit, {
        format: :js,
        id: service_request.id,
        service_request_id: service_request.id,
        sub_service_request_id: ssr.id,
        visit_position: 5,
      }.with_indifferent_access

      assigns(:sub_service_request).should eq ssr
      assigns(:subsidy).should eq subsidy
      assigns(:candidate_per_patient_per_visit).should eq [ service ]
      assigns(:service_request).should eq service_request
    end

    it 'should remove the visit at the given position' do
      post :remove_per_patient_per_visit_visit, {
        format: :js,
        id: service_request.id,
        service_request_id: service_request.id,
        sub_service_request_id: ssr.id,
        visit_position: 5,
      }.with_indifferent_access

      line_item.reload
      line_item.visits.count.should eq 9
      # TODO: test that the right visit was removed
    end

    it 'should call fix_pi_contribution on the subsidy' do
      # TODO
    end

    it 'should create toasts for each of the new visits created' do
      # TODO
    end
  end

  describe 'POST update_from_fulfillment' do
    # TODO
  end

  describe 'POST refresh_service_calendar' do
    it 'should set instance variables' do
      post :refresh_service_calendar, {
        format: :js,
        id: service_request.id,
        service_request_id: service_request.id,
        page: 1,
      }.with_indifferent_access

      session[:service_calendar_page].should eq 1

      assigns(:service_request).should eq service_request
      assigns(:page).should eq 1
      assigns(:tab).should eq 'pricing'
    end
  end
end

