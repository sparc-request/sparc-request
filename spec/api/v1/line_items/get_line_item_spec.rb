# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/line_item/:id.json' do

    before do
      protocol        = build(:protocol_federally_funded)
      protocol.save validate: false
      service         = create(:service_with_pricing_map)
      service_request = build(:service_request, protocol: protocol)
      service_request.save validate: false
      @line_item      = create(:line_item, service: service,
                                            service_request: service_request)
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('line_items', @line_item.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to include('"line_item":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('line_items', @line_item.id, 'shallow') }

      it 'should respond with a single shallow line_item' do
        expect(response.body).to eq("{\"line_item\":{\"sparc_id\":#{@line_item.id},\"callback_url\":\"https://127.0.0.1:5000/v1/line_items/#{@line_item.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('line_items', @line_item.id, 'full') }

      it 'should respond with a Protocol' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:line_item).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'one_time_fee', 'per_unit_cost').
                                sort

        expect(parsed_body['line_item'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('line_items', @line_item.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of line_items and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:line_item).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items_visits', 'service', 'service_request', 'sub_service_request', 'one_time_fee', 'per_unit_cost').
                                sort

        expect(parsed_body['line_item'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
