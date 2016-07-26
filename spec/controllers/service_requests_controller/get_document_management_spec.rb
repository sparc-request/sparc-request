require 'rails_helper'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane

  before :each do
    session[:identity_id] = jug2.id
  end

  describe 'GET document_management' do
    it 'Should set @back to service_calendar if no SSR has or is eligible for a subsidy' do
      organization        = create(:provider)
      service_request     = create(:service_request_without_validations)
      sub_service_request = create(:sub_service_request_without_validations,
                                    service_request_id: service_request.id,
                                    organization_id: organization.id)

      xhr :get, :document_management, id: service_request.id

      expect(assigns(:back)).to eq('service_calendar')
    end

    it 'Should not set @back to service_calendar if no SSR has or is eligible for a subsidy' do
      organization        = create(:provider)
      service_request     = create(:service_request_without_validations)
      sub_service_request = create(:sub_service_request_with_subsidy,
                                    service_request_id: service_request.id,
                                    organization_id: organization.id)

      xhr :get, :document_management, id: service_request.id

      expect(assigns(:back)).to eq('service_subsidy')
    end
  end

end