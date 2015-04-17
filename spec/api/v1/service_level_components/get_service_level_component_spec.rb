require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/service_level_component/:id.json' do

    before { @service_level_component = FactoryGirl.create(:service_level_component) }

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('service_level_components', @service_level_component.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Service root object' do
          expect(response.body).to include('"service_level_component":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('service_level_components', @service_level_component.id, 'shallow') }

      it 'should respond with a single shallow service_level_component' do
        expect(response.body).to eq("{\"service_level_component\":{\"sparc_id\":1,\"callback_url\":\"https://127.0.0.1:5000/v1/service_level_components/1.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('service_level_components', @service_level_component.id, 'full') }

      it 'should respond with a ServiceLevelComponent' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:service_level_component).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'service_id'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['service_level_component'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('service_level_components', @service_level_component.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of services and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:service_level_component).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'service_id'].include?(key) }.
                                push('callback_url', 'sparc_id', 'service').
                                sort

        expect(parsed_body['service_level_component'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
