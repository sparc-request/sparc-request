require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/protocol/:id.json' do

    before do
      @protocol = FactoryGirl.build(:protocol)
      @protocol.save validate: false
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('protocols', @protocol.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to include('"protocol":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('protocols', @protocol.id, 'shallow') }

      it 'should respond with a single shallow protocol with its short title' do
        expect(response.body).to eq("{\"protocol\":{\"sparc_id\":1,\"callback_url\":\"https://sparc.musc.edu/v1/protocols/1.json\",\"short_title\":\"#{@protocol.short_title}\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('protocols', @protocol.id, 'full') }

      it 'should respond with a Protocol' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:protocol).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['protocol'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('protocols', @protocol.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of protocols and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:protocol).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'arms', 'service_requests', 'project_roles', 'human_subjects_info').
                                sort

        expect(parsed_body['protocol'].keys.sort).to eq(expected_attributes)
      end
    end
    
    context 'request for :shallow record with a bogus ID' do
     
     before { cwf_sends_api_get_request_for_resource('protocols', -1, 'shallow') }
     
     it 'should respond with a 404 and JSON content type' do
       expect(response.status).to eq(404)
       expect(response.content_type).to eq('application/json')
       parsed_body         = JSON.parse(response.body)
       expect(parsed_body['protocol']).to eq(nil)
       expect(parsed_body['error']).to eq("Protocol not found for id=-1")
     end
   end
   
   context 'request for :full record with a bogus ID' do
    
    before { cwf_sends_api_get_request_for_resource('protocols', -1, 'full') }
    
    it 'should respond with a 404 and JSON content type' do
      expect(response.status).to eq(404)
      expect(response.content_type).to eq('application/json')
      parsed_body         = JSON.parse(response.body)
      expect(parsed_body['protocol']).to eq(nil)
      expect(parsed_body['error']).to eq("Protocol not found for id=-1")
    end
  end
  
    context 'request for :full_with_shallow_reflections record with a bogus ID' do
   
      before { cwf_sends_api_get_request_for_resource('protocols', -1, 'full_with_shallow_reflections') }
   
      it 'should respond with a 404 and JSON content type' do
        expect(response.status).to eq(404)
        expect(response.content_type).to eq('application/json')
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['protocol']).to eq(nil)
        expect(parsed_body['error']).to eq("Protocol not found for id=-1")
      end
    end
        
  end
end
