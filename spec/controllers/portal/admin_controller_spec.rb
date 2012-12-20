require 'spec_helper'

describe Portal::AdminController, :type => :controller do
  stub_portal_controller

  let!(:identity) { FactoryGirl.create(:identity) }
  let!(:core) { FactoryGirl.create(:core, parent_id: nil) }
  let!(:service_provider)  {FactoryGirl.create(:service_provider, identity_id: identity.id, organization_id: core.id, hold_emails: false)}
  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }
  let!(:sub_service_request1) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }
  let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }

  describe 'GET index' do
    it 'should set service_requests' do  
      session[:identity_id] = identity.id
      get(:index, format: :js)
      assigns(:service_requests).count.should eq 2
      # TODO: check contents of the hash
    end
  end

  describe 'POST delete_toast_message' do
  end
end

