# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/service/:id.json' do

    before { @service = create(:service_with_process_ssrs_organization) }

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('services', @service.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Service root object' do
          expect(response.body).to include('"service":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('services', @service.id, 'shallow') }

      it 'should respond with a single shallow service' do
        expect(response.body).to eq("{\"service\":{\"sparc_id\":#{@service.id},\"callback_url\":\"https://127.0.0.1:5000/v1/services/#{@service.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('services', @service.id, 'full') }

      it 'should respond with a Service' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:service).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'process_ssrs_organization').
                                sort

        expect(parsed_body['service'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('services', @service.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of services and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:service).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'process_ssrs_organization', 'line_items').
                                sort

        expect(parsed_body['service'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
