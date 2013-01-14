require 'spec_helper'

describe Portal::AdminController, :type => :controller do
  stub_portal_controller

  let!(:identity) { FactoryGirl.create(:identity) }
  let!(:core) { FactoryGirl.create(:core, parent_id: nil) }
  let!(:service_provider)  {FactoryGirl.create(:service_provider, identity_id: identity.id, organization_id: core.id, hold_emails: false)}
  let!(:project) {
    project = Project.create(FactoryGirl.attributes_for(:protocol))
    project.save!(validate: false)
    project_role = FactoryGirl.create(
        :project_role,
        protocol_id: project.id,
        identity_id: identity.id,
        project_rights: "approve",
        role: "pi")
    project.reload
    project
  }
  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0, protocol_id: project.id) }
  let!(:sub_service_request1) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }
  let!(:sub_service_request2) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id ) }
  

  let!(:message) {
    ToastMessage.create(
      from:    'CmdrTaco@slashdot.org',
      to:      'esr@fsf.org',
      message: 'happy birthday!')
  }

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

