require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/sub_service_requests/:id.json' do

    before do
      organization          = FactoryGirl.create(:organization)
      @sub_service_request  = FactoryGirl.create(:sub_service_request_with_subsidy, organization: organization)
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('sub_service_requests', @sub_service_request.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Service root object' do
          expect(response.body).to include('"sub_service_request":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('sub_service_requests', @sub_service_request.id, 'shallow') }

      it 'should respond with a single shallow sub_service_request' do
        expect(response.body).to eq("{\"sub_service_request\":{\"sparc_id\":1,\"callback_url\":\"https://127.0.0.1:5000/v1/sub_service_requests/1.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('sub_service_requests', @sub_service_request.id, 'full') }

      it 'should respond with a SubServiceRequest' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = @sub_service_request.attributes.
                                keys.
                                reject! { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'grand_total', 'stored_percent_subsidy').
                                sort

        expect(parsed_body['sub_service_request'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('sub_service_requests', @sub_service_request.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of sub_service_requests and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = @sub_service_request.attributes.
                                keys.
                                reject! { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items', 'service_request', 'grand_total', 'stored_percent_subsidy').
                                sort

        expect(parsed_body['sub_service_request'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
