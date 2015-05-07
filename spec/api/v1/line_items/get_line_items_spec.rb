require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/line_items.json' do

    before do

      protocol        = FactoryGirl.build(:protocol_federally_funded)
      protocol.save validate: false
      service         = FactoryGirl.create(:service_with_pricing_map)
      service_request = FactoryGirl.build(:service_request, protocol: protocol)
      service_request.save validate: false


      5.times do
        @line_item      = FactoryGirl.create(:line_item, service: service,
                                              service_request: service_request)
      end
    end
    context 'response params' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocols root object' do
          expect(response.body).to include('"line_items":')
        end

        it 'should respond with an array of Protocols' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['line_items'].length).to eq(5)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'shallow') }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['line_items'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'full') }

      it 'should respond with an array of line_items and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:line_item).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'one_time_fee', 'per_unit_cost').
                                sort

        expect(parsed_body['line_items'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'full_with_shallow_reflections') }

      it 'should respond with an array of line_items and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:line_item).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.

                                push('callback_url', 'sparc_id', 'line_items_visits', 'service', 'service_request', 'sub_service_request', 'one_time_fee', 'per_unit_cost').
                                sort

        expect(parsed_body['line_items'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
