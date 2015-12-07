require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/line_items_visits.json' do

    before do
      LineItemsVisit.skip_callback(:save, :after, :set_arm_edited_flag_on_subjects)

      5.times do
        line_items_visit = build(:line_items_visit)
        line_items_visit.save validate: false
      end
      
      LineItemsVisit.set_callback(:save, :after, :set_arm_edited_flag_on_subjects)
    end


    context 'response params' do

      before { cwf_sends_api_get_request_for_resources('line_items_visits', 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocols root object' do
          expect(response.body).to include('"line_items_visits":')
        end

        it 'should respond with an array of Protocols' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['line_items_visits'].length).to eq(5)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('line_items_visits', 'shallow') }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['line_items_visits'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('line_items_visits', 'full') }

      it 'should respond with an array of line_items_visits and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:line_items_visit).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['line_items_visits'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('line_items_visits', 'full_with_shallow_reflections') }

      it 'should respond with an array of line_items_visits and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:line_items_visit).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'visits', 'line_item', 'arm').
                                sort

        expect(parsed_body['line_items_visits'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
