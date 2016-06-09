require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/service_request/:id.json' do

    before do
      @service_request = build(:service_request)
      @service_request.save validate: false
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('service_requests', @service_request.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Service root object' do
          expect(response.body).to include('"service_request":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('service_requests', @service_request.id, 'shallow') }

      it 'should respond with a single shallow service_request' do
        expect(response.body).to eq("{\"service_request\":{\"sparc_id\":#{@service_request.id},\"callback_url\":\"https://127.0.0.1:5000/v1/service_requests/#{@service_request.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('service_requests', @service_request.id, 'full') }

      it 'should respond with a Service' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'original_submitted_date'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['service_request'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('service_requests', @service_request.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of service_requests and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'original_submitted_date'].include?(key) }.
                                push('callback_url', 'sparc_id', 'sub_service_requests', 'line_items', 'protocol').
                                sort

        expect(parsed_body['service_request'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
