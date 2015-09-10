require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/clinical_providers.json' do

    before { @clinical_provider = create(:clinical_provider_with_identity_and_organization) }

    context 'response params' do

      before { cwf_sends_api_get_request_for_resources('clinical_providers', 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Services root object' do
          expect(response.body).to include('"clinical_providers":')
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('clinical_providers', 'shallow') }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['clinical_providers'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('clinical_providers', 'full') }

      it 'should respond with an array of clinical_providers and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:clinical_provider).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['clinical_providers'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('clinical_providers', 'full_with_shallow_reflections') }

      it 'should respond with an array of clinical_providers and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:clinical_provider).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'identity', 'organization').
                                sort

        expect(parsed_body['clinical_providers'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
