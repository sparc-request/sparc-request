require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j

  describe 'GET service_details' do

    it 'should add or update arms of ServiceRequest' do
      expect(controller).to receive(:initialize_service_request) do
        controller.instance_eval do
          @service_request = ServiceRequest.new
        end
        expect(controller.instance_variable_get(:@service_request)).to receive(:add_or_update_arms)
      end

      get :service_details, id: 0
    end
  end
end
