require 'rails_helper'

RSpec.describe ServiceRequestsController do

  describe 'GET obtain_research_pricing'
    stub_controller

    let_there_be_lane
    let_there_be_j

    before :each do
      session[:identity_id] = jug2.id
      @protocol = create(:study_without_validations,
                          primary_pi: jug2)
      @organization = create(:provider)
      @service_request = create(:service_request_without_validations,
                                   status: 'draft',
                                   protocol: @protocol)
      @sub_service_request = create(:sub_service_request,
                    service_request_id: @service_request.id,
                    status: 'draft',
                    organization_id: @organization.id)
    end

    context 'Editing a sub_service_request' do
      it 'Should create a past_status for the sub_service_request' do
        xhr :get, :obtain_research_pricing,
                   id: @service_request.id,
                   sub_service_request_id: @sub_service_request.id

        ps = PastStatus.find_by(sub_service_request_id: @sub_service_request.id)

        expect(ps.status).to eq('draft')
      end 
    end

    context 'Editing a service_request' do 
      it 'Should create a past_status for the sub_service_request' do
        xhr :get, :obtain_research_pricing,
             id: @service_request.id

        ps = PastStatus.find_by(sub_service_request_id: @sub_service_request.id)

        expect(ps.status).to eq('draft')
      end
    end

end