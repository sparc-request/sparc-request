require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/sub_service_requests.json' do

    before do
      5.times do
        organization        = create(:organization)
        sub_service_request = create(:sub_service_request, organization: organization)
      end

      @sub_service_request_ids = SubServiceRequest.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'shallow', @sub_service_request_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a SubServiceRequests root object' do
          expect(response.body).to include('"sub_service_requests":')
        end

        it 'should respond with an array of SubServiceRequests' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['sub_service_requests'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'shallow', @sub_service_request_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['sub_service_requests'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'full', @sub_service_request_ids) }

      it 'should respond with an array of sub_service_requests and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:sub_service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'grand_total').
                                sort

        expect(parsed_body['sub_service_requests'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'full_with_shallow_reflections', @sub_service_request_ids) }

      it 'should respond with an array of sub_service_requests and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:sub_service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items', 'service_request', 'grand_total').
                                sort

        expect(parsed_body['sub_service_requests'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
