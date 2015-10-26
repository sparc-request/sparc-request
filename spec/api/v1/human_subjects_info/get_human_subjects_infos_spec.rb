require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/human_subjects_infos.json' do

    before do
      5.times do
        human_subjects_info = FactoryGirl.build(:human_subjects_info, pro_number: nil, hr_number: nil)
        @study = FactoryGirl.build(:study, human_subjects_info: human_subjects_info)
        @study.save(validate: false)
      end
    end


    context 'response params' do

      before { cwf_sends_api_get_request_for_resources('human_subjects_infos', 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Human Subjects Infos root object' do
          expect(response.body).to include('"human_subjects_info":')
        end

        it 'should respond with an array of Human Subjects Infos' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['human_subjects_info'].length).to eq(5)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('human_subjects_infos', 'shallow') }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['human_subjects_info'].map(&:keys).flatten.uniq.sort).to eq(['callback_url', 'sparc_id'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('human_subjects_infos', 'full') }

      it 'should respond with an array of human_subjects_info and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:human_subjects_info).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['human_subjects_infos'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('human_subjects_infos', 'full_with_shallow_reflections') }

      it 'should respond with an array of human_subjects_info and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:human_subjects_info).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'protocol').
                                sort

        expect(parsed_body['human_subjects_infos'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
