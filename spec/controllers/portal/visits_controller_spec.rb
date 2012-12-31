require 'spec_helper'

describe Portal::VisitsController do
  stub_portal_controller

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service) {
    service = FactoryGirl.create(
        :service,
        organization: core,
        pricing_map_count: 1)
    service.pricing_maps[0].display_date = Date.today
    service
  }

  let!(:service_request) {
    FactoryGirl.create(
      :service_request,
      visit_count: 0,
      subject_count: 1)
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

  let!(:line_item) {
    FactoryGirl.create(
        :line_item,
        service_id: service.id,
        service_request_id: service_request.id,
        sub_service_request_id: ssr.id)
  }

  let!(:visit) {
    FactoryGirl.create(
        :visit,
        line_item_id:
        line_item.id, research_billing_qty: 5)
  }

  describe 'POST update_from_fulfillment' do
    # TODO
  end

  describe 'destroy' do
    it 'should set instance variables' do
      post :destroy, {
        format: :js,
        id: visit.id,
      }.with_indifferent_access
      assigns(:visit).should eq visit
      assigns(:sub_service_request).should eq ssr
      assigns(:service_request).should eq service_request
      assigns(:subsidy).should eq subsidy
      assigns(:candidate_per_patient_per_visit).should eq [ service ]
    end
  end
end

