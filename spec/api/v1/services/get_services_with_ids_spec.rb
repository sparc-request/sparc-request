require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/services.json' do

    before do

      FactoryGirl.create_list(:service_with_process_ssrs_organization, 5)

      @service_ids = Service.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('services', 'shallow', @service_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Services root object' do
          expect(response.body).to include('"services":')
        end

        it 'should respond with an array of Services' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['services'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('services', 'shallow', @service_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['services'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('services', 'full', @service_ids) }

      it 'should respond with an array of services and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:service).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'process_ssrs_organization').
                                sort

        expect(parsed_body['services'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('services', 'full_with_shallow_reflections', @service_ids) }

      it 'should respond with an array of services and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:service).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'process_ssrs_organization', 'line_items', 'service_level_components').
                                sort

        expect(parsed_body['services'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
