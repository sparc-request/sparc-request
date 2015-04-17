require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/service_level_components.json' do

    before do
      FactoryGirl.create(:service_with_service_level_components)

      @service_level_component_ids = ServiceLevelComponent.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('service_level_components', 'shallow', @service_level_component_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Services root object' do
          expect(response.body).to include('"service_level_components":')
        end

        it 'should respond with an array of Services' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['service_level_components'].length).to eq(3)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('service_level_components', 'shallow', @service_level_component_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['service_level_components'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('service_level_components', 'full', @service_level_component_ids) }

      it 'should respond with an array of service_level_components and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:service_level_component).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'service_id'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['service_level_components'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('service_level_components', 'full_with_shallow_reflections', @service_level_component_ids) }

      it 'should respond with an array of service_level_components and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:service_level_component).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'service_id'].include?(key) }.
                                push('callback_url', 'sparc_id', 'service').
                                sort

        expect(parsed_body['service_level_components'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
