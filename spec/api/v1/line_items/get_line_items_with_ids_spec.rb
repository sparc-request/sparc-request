require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/line_items.json' do

    before do
      5.times do
        line_item = FactoryGirl.build(:line_item)
        line_item.save validate: false
      end

      @line_item_ids = LineItem.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'shallow', @line_item_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a LineItems root object' do
          expect(response.body).to include('"line_items":')
        end

        it 'should respond with an array of LineItems' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['line_items'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'shallow', @line_item_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['line_items'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'full', @line_item_ids) }

      it 'should respond with an array of line_items and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:line_item).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['line_items'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('line_items', 'full_with_shallow_reflections', @line_item_ids) }

      it 'should respond with an array of line_items and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:line_item).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items_visits', 'service', 'service_request', 'sub_service_request').
                                sort

        expect(parsed_body['line_items'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
