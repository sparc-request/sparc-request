require 'spec_helper'

describe Portal::SubServiceRequestsController do
  stub_portal_controller

  let!(:identity) { FactoryGirl.create(:identity) }

  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:study) { study = Study.create(FactoryGirl.attributes_for(:protocol)); study.save!(:validate => false); study }

  let!(:service_request) {
    FactoryGirl.create(
      :service_request,
      protocol_id: study.id)
  }

  let!(:ssr) {
    FactoryGirl.create(
        :sub_service_request,
        service_request_id: service_request.id,
        organization_id: core.id)
  }

  describe 'show' do
    it 'should set sub_service_request' do
      session[:identity_id] = identity.id
      get :show, {
        format: :js,
        id: ssr.id,
      }.with_indifferent_access

      assigns(:sub_service_request).should eq ssr
    end

    # TODO: test for case where use can edit fulfillment
    # TODO: test for case where use cannot edit fulfillment
  end

  describe 'update_from_fulfillment' do
    # TODO
  end

  describe 'add_line_item' do
    let!(:core)                 { FactoryGirl.create(:core) }
    let!(:service)              { FactoryGirl.create(:service, organization_id: core.id, ) }

    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/javascript" 
    end

    it 'should work (smoke test)' do
      service_request = FactoryGirl.create(
          :service_request)
      sub_service_request = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request.id,
          organization_id:    core.id)

      post(
          :add_line_item,
          :id              => sub_service_request.id,
          :new_service_id  => service.id)

      service_request.reload
      service_request.line_items.count.should eq 1
      service_request.line_items[0].quantity.should eq nil
      service_request.line_items[0].visits.count.should eq 5
    end

    it 'should work when the service request visit count is nil' do
      # TODO: does this test still make sense?

      service_request = FactoryGirl.create(
          :service_request,
          subject_count: 5,
          visit_count:   nil)
      sub_service_request = FactoryGirl.create(
          :sub_service_request,
          service_request_id: service_request.id,
          organization_id:    core.id)

      post(
          :add_line_item,
          :id              => sub_service_request.id,
          :new_service_id  => service.id)

      service_request.reload
      service_request.line_items.reload
      service_request.line_items.count.should eq 1
      service_request.line_items[0].quantity.should eq nil
      service_request.line_items[0].visits.count.should eq 1
    end
  end

  describe 'new_document' do
    # TODO
  end

  describe 'delete_documents' do
    # TODO
  end

  describe 'edit_documents' do
    # TODO
  end

  describe 'destroy' do
    # TODO
  end
end

