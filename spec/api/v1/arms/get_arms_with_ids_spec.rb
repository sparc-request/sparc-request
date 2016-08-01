# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/arms.json' do

    before do
      5.times do
        arm = build(:arm)
        arm.save validate: false
      end

      @arm_ids = Arm.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('arms', 'shallow', @arm_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Arms root object' do
          expect(response.body).to include('"arms":')
        end

        it 'should respond with an array of Arms' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['arms'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('arms', 'shallow', @arm_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['arms'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('arms', 'full', @arm_ids) }

      it 'should respond with an array of arms and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:arm).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['arms'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('arms', 'full_with_shallow_reflections', @arm_ids) }

      it 'should respond with an array of arms and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:arm).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items_visits', 'visit_groups', 'protocol').
                                sort

        expect(parsed_body['arms'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
