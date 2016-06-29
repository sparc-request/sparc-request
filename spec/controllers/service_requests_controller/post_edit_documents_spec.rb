require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j

  describe 'POST edit_documents' do
    let!(:protocol)             { create(:protocol_without_validations, primary_pi: jug2) }
    let!(:service_request)      { create(:service_request_without_validations, protocol: protocol) }
    let!(:organization)         { create(:organization) }
    let!(:sub_service_request)  { create(:sub_service_request_without_validations, service_request: service_request, organization: organization) }
    let!(:doc)                  { create(:document, protocol: protocol) }

    before(:each) do
      doc.sub_service_requests << sub_service_request
      session[:service_request_id] = service_request.id
      allow(controller).to receive(:initialize_service_request) do
        controller.instance_eval do
          @service_request = ServiceRequest.find(session[:service_request_id])
        end
        allow(controller.instance_variable_get(:@service_request)).to receive(:service_list) { :service_list }
      end
    end

    it 'should set @document' do
      post :edit_documents, {
        id: service_request.id,
        document_id: doc.id,
        format: :js
      }.with_indifferent_access
      expect(assigns(:document)).to eq doc
    end

    it 'should set @service_list' do
      post :edit_documents, {
        id: service_request.id,
        document_id: doc.id,
        format: :js
      }.with_indifferent_access
      expect(assigns(:service_list)).to eq :service_list
    end
  end
end
