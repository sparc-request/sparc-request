require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/identity/:id.json' do

    before { @identity = FactoryGirl.create(:identity) }

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('identities', @identity.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Identity root object' do
          expect(response.body).to include('"identity":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('identities', @identity.id, 'shallow') }

      it 'should respond with a single shallow identity' do
        expect(response.body).to eq("{\"identity\":{\"sparc_id\":1,\"callback_url\":\"https://127.0.0.1:5000/v1/identities/1.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('identities', @identity.id, 'full') }

      it 'should respond with a Identity' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid'].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['identity'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('identities', @identity.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of identities and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = ['email', 'first_name', 'last_name', 'ldap_uid', 'protocols'].
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['identity'].keys.sort).to eq(expected_attributes)
      end
    end
    
    context 'request for :shallow record with a bogus ID' do
     
     before { cwf_sends_api_get_request_for_resource('identities', -1, 'shallow') }
     
     it 'should respond with a 404 and JSON content type' do
       expect(response.status).to eq(404)
       expect(response.content_type).to eq('application/json')
       parsed_body         = JSON.parse(response.body)
       expect(parsed_body['identity']).to eq(nil)
       expect(parsed_body['error']).to eq("Identity not found for id=-1")
     end
   end
   
   context 'request for :full record with a bogus ID' do
    
    before { cwf_sends_api_get_request_for_resource('identities', -1, 'full') }
    
    it 'should respond with a 404 and JSON content type' do
      expect(response.status).to eq(404)
      expect(response.content_type).to eq('application/json')
      parsed_body         = JSON.parse(response.body)
      expect(parsed_body['identity']).to eq(nil)
      expect(parsed_body['error']).to eq("Identity not found for id=-1")
    end
  end
  
    context 'request for :full_with_shallow_reflections record with a bogus ID' do
   
      before { cwf_sends_api_get_request_for_resource('identities', -1, 'full_with_shallow_reflections') }
   
      it 'should respond with a 404 and JSON content type' do
        expect(response.status).to eq(404)
        expect(response.content_type).to eq('application/json')
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['identity']).to eq(nil)
        expect(parsed_body['error']).to eq("Identity not found for id=-1")
      end
    end
  end
end
