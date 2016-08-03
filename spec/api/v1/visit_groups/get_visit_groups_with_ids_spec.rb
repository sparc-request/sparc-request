require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/visit_groups.json' do

    before do
      5.times do
        visit_group = build(:visit_group)
        visit_group.save validate: false
      end

      @visit_group_ids = VisitGroup.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('visit_groups', 'shallow', @visit_group_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a VisitGroups root object' do
          expect(response.body).to include('"visit_groups":')
        end

        it 'should respond with an array of VisitGroups' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['visit_groups'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('visit_groups', 'shallow', @visit_group_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['visit_groups'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('visit_groups', 'full', @visit_group_ids) }

      it 'should respond with an array of visit_groups and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:visit_group).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['visit_groups'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('visit_groups', 'full_with_shallow_reflections', @visit_group_ids) }

      it 'should respond with an array of visit_groups and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:visit_group).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'visits', 'arm').
                                sort

        expect(parsed_body['visit_groups'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
