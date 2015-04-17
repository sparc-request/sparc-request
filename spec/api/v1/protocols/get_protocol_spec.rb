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

      it 'should respond with a single shallow protocol' do
        expect(response.body).to eq("{\"protocol\":{\"sparc_id\":1,\"callback_url\":\"https://127.0.0.1:5000/v1/protocols/1.json\"}}")
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
                                push('callback_url', 'sparc_id', 'arms', 'service_requests', 'project_roles').
                                sort

        expect(parsed_body['protocol'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
