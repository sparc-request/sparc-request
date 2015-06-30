require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/protocols.json' do

    before do
      5.times do
        protocol = FactoryGirl.build(:protocol)
        protocol.save validate: false
      end

      @protocol_ids = Protocol.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('protocols', 'shallow', @protocol_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Services root object' do
          expect(response.body).to include('"protocols":')
        end

        it 'should respond with an array of Services' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['protocols'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('protocols', 'shallow', @protocol_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['protocols'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('protocols', 'full', @protocol_ids) }

      it 'should respond with an array of protocols and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:protocol).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['protocols'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('protocols', 'full_with_shallow_reflections', @protocol_ids) }

      it 'should respond with an array of protocols and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:protocol).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'arms', 'service_requests', 'project_roles').
                                sort

        expect(parsed_body['protocols'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
