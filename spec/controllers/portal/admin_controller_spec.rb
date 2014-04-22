require 'spec_helper'

describe Portal::AdminController, :type => :controller do
  stub_portal_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  let!(:identity)             { FactoryGirl.create(:identity) }
  let!(:service_provider)     { FactoryGirl.create(:service_provider, identity_id: identity.id, organization_id: core.id, hold_emails: false) }
  let!(:message) { ToastMessage.create(from: 'CmdrTaco@slashdot.org', to: 'esr@fsf.org', message: 'happy birthday!') }

  before :each do
    @service_request = ServiceRequest.new(FactoryGirl.attributes_for(:service_request, :protocol_id => project.id))
    @service_request.save(:validate => false)
    @project_role = FactoryGirl.create(:project_role, protocol_id: project.id, identity_id: identity.id, project_rights: "approve", role: "primary_pi") 
    @sub_service_request1 = FactoryGirl.create(:sub_service_request, status: 'yo_mama', service_request_id: @service_request.id, organization_id: core.id ) 
    @sub_service_request2 = FactoryGirl.create(:sub_service_request, status: 'his_mama', service_request_id: @service_request.id, organization_id: core.id ) 
  end
  
  describe 'GET index' do
    it 'should set service_requests' do  
      session[:identity_id] = identity.id
      get(:index, format: :js)
      assigns(:service_requests).count.should eq 2
      # TODO: check contents of the hash
    end
  end

  describe 'POST delete_toast_message' do
    it 'should set message' do
      get(:delete_toast_message, {
        format: :js,
        id: message.id,
      }.with_indifferent_access)
      assigns(:message).should eq message
    end

    it 'should delete the message' do
      get(:delete_toast_message, {
        format: :js,
        id: message.id,
      }.with_indifferent_access)
      expect { message.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end

