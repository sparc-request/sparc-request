require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/arm/:id.json' do

    before do
      @arm = build(:arm)
      @arm.save validate: false
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('arms', @arm.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to include('"arm":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('arms', @arm.id, 'shallow') }

      it 'should respond with a single shallow arm' do
        expect(response.body).to eq("{\"arm\":{\"sparc_id\":#{@arm.id},\"callback_url\":\"https://127.0.0.1:5000/v1/arms/#{@arm.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('arms', @arm.id, 'full') }

      it 'should respond with a Protocol' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:arm).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['arm'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('arms', @arm.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of arms and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:arm).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items_visits', 'visit_groups', 'protocol').
                                sort

        expect(parsed_body['arm'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
