# Copyright © 2011-2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'SPARCCWF::APIv1', type: :request do

  describe 'GET /v1/irb_records/:id.json' do

    before do
      @irb_record = create(:irb_record)
    end

    context 'response params' do
      before { cwf_sends_api_get_request_for_resource('irb_records', @irb_record.id, 'shallow') }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a irb_record root object' do
          expect(response.body).to include('"irb_record":')
        end
      end
    end

    context 'request for :shallow record' do

      before { cwf_sends_api_get_request_for_resource('irb_records', @irb_record.id, 'shallow') }

      it 'should respond with a single shallow irb_record' do
        expect(response.body).to eq("{\"irb_record\":{\"sparc_id\":#{@irb_record.id},\"callback_url\":\"https://127.0.0.1:5000/v1/irb_records/#{@irb_record.id}.json\"}}")
      end
    end

    context 'request for :full record' do

      before { cwf_sends_api_get_request_for_resource('irb_records', @irb_record.id, 'full') }

      it 'should respond with an IrbRecord' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:irb_record).attributes.
                                keys.
                                reject{ |key| ['id','created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'study_phase_values').
                                sort

        expect(parsed_body['irb_record'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections record' do

      before { cwf_sends_api_get_request_for_resource('irb_records', @irb_record.id, 'full_with_shallow_reflections') }

      it 'should respond with an array of irb_record and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:irb_record).attributes.
                                keys.
                                reject{ |key| ['id', 'created_at', 'updated_at', 'deleted_at'].include?(key) }.
                                push('callback_url', 'sparc_id', 'study_phase_values', 'human_subjects_info').
                                sort

        expect(parsed_body['irb_record'].keys.sort).to eq(expected_attributes)
      end
    end

    context 'request for :shallow record with a bogus ID' do

     before { cwf_sends_api_get_request_for_resource('irb_records', -1, 'shallow') }

     it 'should respond with a 404 and JSON content type' do
       expect(response.status).to eq(404)
       expect(response.content_type).to eq('application/json')
       parsed_body         = JSON.parse(response.body)
       expect(parsed_body['irb_record']).to eq(nil)
       expect(parsed_body['error']).to eq("IrbRecord not found for id=-1")
     end
   end

   context 'request for :full record with a bogus ID' do

    before { cwf_sends_api_get_request_for_resource('irb_records', -1, 'full') }

    it 'should respond with a 404 and JSON content type' do
      expect(response.status).to eq(404)
      expect(response.content_type).to eq('application/json')
      parsed_body         = JSON.parse(response.body)
      expect(parsed_body['irb_record']).to eq(nil)
      expect(parsed_body['error']).to eq("IrbRecord not found for id=-1")
    end
  end

    context 'request for :full_with_shallow_reflections record with a bogus ID' do

      before { cwf_sends_api_get_request_for_resource('irb_records', -1, 'full_with_shallow_reflections') }

      it 'should respond with a 404 and JSON content type' do
        expect(response.status).to eq(404)
        expect(response.content_type).to eq('application/json')
        parsed_body         = JSON.parse(response.body)
        expect(parsed_body['irb_record']).to eq(nil)
        expect(parsed_body['error']).to eq("IrbRecord not found for id=-1")
      end
    end
  end
end
