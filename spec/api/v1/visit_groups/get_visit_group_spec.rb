require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/visit_group/:id.json' do

    before do
      VisitGroup.skip_callback(:save, :after, :set_arm_edited_flag_on_subjects)

      @visit_group = create(:visit_group)
    end

    context 'response params' do

      before { cwf_sends_api_get_request_for_resource('visit_groups', @visit_group.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to include('"visit_group":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('visit_groups', @visit_group.id, 'shallow') }

      it 'should respond with a single shallow visit_group' do
        expect(response.body).to eq("{\"visit_group\":{\"sparc_id\":#{@visit_group.id},\"callback_url\":\"https://127.0.0.1:5000/v1/visit_groups/#{@visit_group.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('visit_groups', @visit_group.id, 'full') }

      it 'should respond with a Protocol' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:visit_group).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['visit_group'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('visit_groups', @visit_group.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of visit_groups and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:visit_group).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'visits', 'arm').
                                sort

        expect(parsed_body['visit_group'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
