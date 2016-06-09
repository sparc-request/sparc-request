require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request

  describe 'POST edit_documents' do
    let!(:doc) { Document.create(service_request_id: service_request.id) }

    before(:each) do
      doc.update_attribute(:id, 1)
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
