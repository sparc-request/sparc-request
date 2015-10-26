require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/clinical_provider/:id.json' do

    before { @clinical_provider = create(:clinical_provider_with_identity_and_organization) }

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('clinical_providers', @clinical_provider.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a ClinicalProvider root object' do
          expect(response.body).to include('"clinical_provider":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('clinical_providers', @clinical_provider.id, 'shallow') }

      it 'should respond with a single shallow clinical_provider' do
        expect(response.body).to eq("{\"clinical_provider\":{\"sparc_id\":#{@clinical_provider.id},\"callback_url\":\"https://127.0.0.1:5000/v1/clinical_providers/#{@clinical_provider.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('clinical_providers', @clinical_provider.id, 'full') }

      it 'should respond with a ClinicalProvider' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:clinical_provider).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['clinical_provider'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('clinical_providers', @clinical_provider.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of clinical_providers and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:clinical_provider).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'identity', 'organization').
                                sort

        expect(parsed_body['clinical_provider'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
