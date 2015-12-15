require 'rails_helper'

RSpec.describe ServiceRequestsController do

  describe 'GET document_management' do

    stub_controller

    let_there_be_lane
    let_there_be_j
    build_service_request

    before(:each) do
      # stub initialize_service_request so we can stub @service_request's
      # service_list method
      expect(controller).to receive(:initialize_service_request) do
        controller.instance_eval do
          @service_request = ServiceRequest.find_by_id(params[:id])
        end
        expect(controller.instance_variable_get(:@service_request)).to receive(:service_list) { :service_list }
      end
    end

    context 'ServiceRequest has no Subsidies' do
      before(:each) do
        xhr :get, :document_management, id: service_request.id        
      end

      it "should set the service list to the service request's service list" do
        expect(assigns(:service_list)).to eq :service_list
      end

      it "should set @back to 'service_calendar'" do
        expect(assigns(:back)).to eq 'service_calendar'
      end
    end

    context 'ServiceRequest has Subsidies' do
      before(:each) do
        create(:subsidy, sub_service_request: service_request.sub_service_requests.first)
        xhr :get, :document_management, id: service_request.id
      end

      it "should set @service_list to the ServiceRequest's service list" do
        expect(assigns(:service_list)).to eq :service_list
      end
    end
  end
end
