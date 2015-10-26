require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/identities.json' do

    before do
      create_list(:identity, 5)

      @identity_ids = Identity.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('identities', 'shallow', @identity_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Identities root object' do
          expect(response.body).to include('"identities":')
        end

        it 'should respond with an array of Identities' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['identities'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('identities', 'shallow', @identity_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['identities'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('identities', 'full', @identity_ids) }

      it 'should respond with an array of identities and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid'].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['identities'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('identities', 'full_with_shallow_reflections', @identity_ids) }

      it 'should respond with an array of identities and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['identities'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
