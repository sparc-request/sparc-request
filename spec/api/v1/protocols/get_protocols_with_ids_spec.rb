# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

  describe 'GET /v1/protocols.json' do

    before do
      5.times do
        protocol = build(:protocol)
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
        expected_attributes = build(:protocol).attributes.
                                keys.
                                reject { |key| ['study_phase', 'id', 'created_at', 'updated_at', 'deleted_at', 'research_master_id', 'sub_service_requests_count', 'rmid_validated', 'locked', 'budget_agreed_upon_date', 'initial_budget_sponsor_received_date', 'initial_amount', 'negotiated_amount', 'initial_amount_clinical_services', 'negotiated_amount_clinical_services', 'guarantor_contact', 'guarantor_phone', 'guarantor_email'].include?(key) }.
                                push('callback_url', 'sparc_id').
                                sort
        expect(parsed_body['protocols'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('protocols', 'full_with_shallow_reflections', @protocol_ids) }

      it 'should respond with an array of protocols and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:protocol).attributes.
                                keys.
                                reject { |key| ['study_phase', 'id', 'created_at', 'updated_at', 'deleted_at', 'research_master_id', 'sub_service_requests_count', 'rmid_validated', 'locked', 'budget_agreed_upon_date', 'initial_budget_sponsor_received_date', 'initial_amount', 'negotiated_amount', 'initial_amount_clinical_services', 'negotiated_amount_clinical_services', 'guarantor_contact', 'guarantor_phone', 'guarantor_email'].include?(key) }.
                                push('callback_url', 'sparc_id', 'arms', 'service_requests', 'project_roles', 'human_subjects_info').
                                sort

        expect(parsed_body['protocols'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
