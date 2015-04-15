require 'spec_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/human_subjects_infos/:id.json' do

    before do
      human_subjects_info = FactoryGirl.build(:human_subjects_info, pro_number: nil, hr_number: nil)
      @study = FactoryGirl.build(:study, human_subjects_info: human_subjects_info)
      @study.save(validate: false)
      
    end

    context 'response params' do
      before { cwf_sends_api_get_request_for_resource('human_subjects_infos', @study.human_subjects_info.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a Protocol root object' do
          expect(response.body).to include('"human_subjects_info":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('human_subjects_infos', @study.human_subjects_info.id, 'shallow') }

      it 'should respond with a single shallow human_subjects_info' do
        expect(response.body).to eq("{\"human_subjects_info\":{\"sparc_id\":1,\"callback_url\":\"https://sparc.musc.edu/v1/human_subjects_infos/1.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('human_subjects_infos', @study.human_subjects_info.id, 'full') }

      it 'should respond with a HumanSubjectsInfo' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:human_subjects_info).attributes.
                                keys.
                                reject { |key| ['id','created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort

        expect(parsed_body['human_subjects_info'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('human_subjects_infos', @study.human_subjects_info.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of human_subjects_info and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = FactoryGirl.build(:human_subjects_info).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'protocol').
                                sort

        expect(parsed_body['human_subjects_info'].keys.sort).to eq(expected_attributes)
      end
    end
  end
end
