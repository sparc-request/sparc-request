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

      it 'should set subsidies to an empty array if there are no sub service requests' do
        expect(assigns(:subsidies)).to eq [ ]
      end

      it 'should redirect to document_management' do
        expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
      end
    end

    context 'SubServiceRequest has a Subsidy' do

      before(:each) { get :service_subsidy, id: service_request.id }

      it 'should put the Subsidy into @subsidies' do
        expect(assigns(:subsidies)).to eq [ subsidy ]
      end

      it 'should responsd with status 200' do
        expect(response.status).to eq 200
      end
    end

    context 'ServiceRequest has Subsidies but not current SubServiceRequest' do

      let!(:core2)            { create(:core, parent_id: program.id) }
      let!(:ssr_no_subsidies) { create(:sub_service_request, service_request: service_request, organization: core2) }

      before(:each) do
        session[:sub_service_request_id] = ssr_no_subsidies.id
        get :service_subsidy, id: service_request.id
      end

      it 'should redirect to document_management' do
        expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
      end
    end

    context 'SubServiceRequest does not have a Study and is eligible for one' do

      before(:each) do
        sub_service_request.organization.subsidy_map.update_attributes(
          max_dollar_cap: 100,
          max_percentage: 100)

        get :service_subsidy, id: service_request.id
      end

      it 'should create a new Subsidy and put it into @subsidies' do
        expect(assigns(:subsidies).map { |s| s.class}).to eq [ Subsidy ]
      end
    end

    context 'with subsidy maps' do

      let!(:core_subsidy_map)     { create(:subsidy_map, organization_id: core.id) }
      let!(:provider_subsidy_map) { create(:subsidy_map, organization_id: provider.id) }
      let!(:program_subsidy_map)  { subsidy_map }

      context 'SubServiceRequest does not have a subsidy and is not eligible for one' do

        before(:each) do
          # destroy the subsidy; we want to ensure that #service_subsidy
          # doesn't create a subsidy
          sub_service_request.subsidy.destroy

          core.build_subsidy_map
          provider.build_subsidy_map
          program.build_subsidy_map

          core.subsidy_map.update_attributes!(
            max_dollar_cap: 0,
            max_percentage: 0)
          provider.subsidy_map.update_attributes!(
            max_dollar_cap: 0,
            max_percentage: 0)
          program.subsidy_map.update_attributes!(
            max_dollar_cap: 0,
            max_percentage: 0)

          # make sure before we start the test that the ssr is not
          # eligible for subsidy
          expect(sub_service_request.eligible_for_subsidy?).to eq false

          # call service_subsidy
          get :service_subsidy, id: service_request.id

          sub_service_request.reload
        end

        it 'should not create a new subsidy' do
          # Now the ssr should not have a subsidy
          subsidy = sub_service_request.subsidy
          expect(subsidy).to eq nil

          expect(assigns(:subsidies)).to eq [ ]
        end

        it 'should redirect to document_management' do
          expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
        end
      end
    end
  end
end
