require 'rails_helper'

RSpec.describe ServiceRequestsController do

  describe 'GET document_management' do

    stub_controller

    let_there_be_lane
    let_there_be_j
    build_service_request

    before(:each) { session[:service_request_id] = service_request.id }

    context 'ServiceRequest has subsidies' do

      before(:each) do
        create(:subsidy, sub_service_request: service_request.sub_service_requests.first)

        allow(controller).to receive(:initialize_service_request) do
          controller.instance_eval do
            @service_request = ServiceRequest.find_by_id(session[:service_request_id])
            @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
          end
          allow(controller.instance_variable_get(:@service_request)).to receive(:service_list) { :service_list }
        end

        get :document_management, id: service_request.id
      end

      it "should set the service list to the service request's service list" do
        expect(assigns(:service_list)).to eq :service_list
      end

      it "should not set @back" do
        expect(assigns(:back)).to eq 'service_subsidy'
      end
    end

    context 'ServiceRequest has no subsidies' do

      before(:each) do
        allow(controller).to receive(:initialize_service_request) do
          controller.instance_eval do
            @service_request = ServiceRequest.find_by_id(session[:service_request_id])
            @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
          end
          allow(controller.instance_variable_get(:@service_request)).to receive(:service_list) { :service_list }
        end
        get :document_management, id: service_request.id
      end

      it "should set the service list to the service request's service list" do
        expect(assigns(:service_list)).to eq :service_list
      end

      it "should set @back to 'service_calendar'" do
        expect(assigns(:back)).to eq 'service_calendar'
      end
    end
  end
end
