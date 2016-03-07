require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/service_requests.json' do

    before do
      5.times do
        service_request = build(:service_request)
        service_request.save validate: false
      end
    end


    context 'response params' do

      before { cwf_sends_api_get_request_for_resources('service_requests', 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a SubServiceRequests root object' do
          expect(response.body).to include('"service_requests":')
        end

      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('service_requests', 'shallow') }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['service_requests'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('service_requests', 'full') }

      it 'should respond with an array of service_requests and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'original_submitted_date'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['service_requests'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('service_requests', 'full_with_shallow_reflections') }

      it 'should respond with an array of service_requests and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'original_submitted_date'].include?(key) }.
                                push('callback_url', 'sparc_id', 'sub_service_requests', 'line_items', 'protocol').
                                sort

        expect(parsed_body['service_requests'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
