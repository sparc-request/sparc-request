require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  describe 'GET service_subsidy' do

    before(:each) { session[:service_request_id] = service_request.id }

    context 'no SubServiceRequests' do

      before(:each) do
        service_request.sub_service_requests.each { |ssr| ssr.destroy }
        service_request.reload
        get :service_subsidy, id: service_request.id
      end

      it 'should set has_subsidies to false if there are no sub service requests' do
        expect(assigns(:has_subsidy)).to eq false
      end

      it 'should set eligible for subsidy to false if there are no sub service requests' do
        expect(assigns(:eligible_for_subsidy)).to eq false
      end

      it 'should redirect to document_management' do
        expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
      end
    end

    context 'SubServiceRequest has a Subsidy' do

      before(:each) { get :service_subsidy, id: service_request.id }

      it 'has subsidy should return true' do
        expect(assigns(:has_subsidy)).to eq true
      end

      it 'should responsd with status 200' do
        expect(response.status).to eq 200
      end
    end

    context 'SubServiceRequest does not have a subsidy but is eligible for one' do

      before(:each) do
        sub_service_request.subsidies.destroy_all
        sub_service_request.reload
        sub_service_request.organization.subsidy_map.update_attributes(
          max_dollar_cap: 100,
          max_percentage: 100)

        get :service_subsidy, id: service_request.id
      end

      it 'has subsidy should return false' do
        expect(assigns(:has_subsidy)).to eq false
      end

      it 'eligible for subsidy should return true' do
        expect(assigns(:eligible_for_subsidy)).to eq true
      end
    end

    context 'with sub service request' do
      context 'SubServiceRequest does not have a subsidy and is not eligible for one' do

        before(:each) do
          subsidy.destroy
          subsidy_map.destroy
          # make sure before we start the test that the ssr is not eligible for subsidy
          expect(sub_service_request.eligible_for_subsidy?).to eq false

          # call service_subsidy
          get :service_subsidy, id: service_request.id

          sub_service_request.reload
        end

        it 'should redirect to document_management' do
          expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
        end
      end
    end
  end
end
