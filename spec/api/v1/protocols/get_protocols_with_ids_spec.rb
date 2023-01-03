# Copyright © 2011-2022 MUSC Foundation for Research Development~
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
  describe 'GET /api/v1/protocols.json' do
    let!(:protocols) { create_list(:protocol_without_validations, 5) }

    context 'with ids' do
      context 'request for :shallow records' do
        before { send_api_get_request(resource: 'protocols', ids: protocols.first(4).map(&:id), depth: 'shallow') }

        it 'should respond with an array of shallow protocols' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['protocols']).to eq(
            protocols.first(4).map{ |p| { 
              'sparc_id'      => p.id,
              'callback_url'  => p.remote_service_callback_url
            }}
          )
        end
      end

      context 'request for :full records' do
        before { send_api_get_request(resource: 'protocols', ids: protocols.first(4).map(&:id), depth: 'full') }

        it 'should respond with an array of protocols and their attributes' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['protocols']).to eq(
            protocols.first(4).map{ |p| 
              p.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at','study_phase', 'research_master_id', 'sub_service_requests_count', 'rmid_validated', 'locked', 'budget_agreed_upon_date', 'initial_budget_sponsor_received_date', 'initial_amount', 'negotiated_amount', 'initial_amount_clinical_services', 'negotiated_amount_clinical_services', 'guarantor_contact', 'guarantor_phone', 'guarantor_email', 'default_billing_type').
              merge({ 
                'sparc_id'                      => p.id,
                'callback_url'                  => p.remote_service_callback_url,
                'start_date'                    => p.start_date.to_s(:iso8601),
                'end_date'                      => p.end_date.to_s(:iso8601),
                'funding_start_date'            => p.funding_start_date.to_s(:iso8601),
                'indirect_cost_rate'            => p.indirect_cost_rate.to_f.to_s
              })
            }
          )
        end
      end

      context 'request for :full_with_shallow_reflections records' do
        before { send_api_get_request(resource: 'protocols', ids: protocols.first(4).map(&:id), depth: 'full_with_shallow_reflections') }

        it 'should respond with an array of protocols and their attributes and their shallow reflections' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['protocols']).to eq(
            protocols.first(4).map{ |p| 
              p.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at','study_phase', 'research_master_id', 'sub_service_requests_count', 'rmid_validated', 'locked', 'budget_agreed_upon_date', 'initial_budget_sponsor_received_date', 'initial_amount', 'negotiated_amount', 'initial_amount_clinical_services', 'negotiated_amount_clinical_services', 'guarantor_contact', 'guarantor_phone', 'guarantor_email', 'default_billing_type').
              merge({ 
                'sparc_id'                      => p.id,
                'callback_url'                  => p.remote_service_callback_url,
                'start_date'                    => p.start_date.to_s(:iso8601),
                'end_date'                      => p.end_date.to_s(:iso8601),
                'funding_start_date'            => p.funding_start_date.to_s(:iso8601),
                'indirect_cost_rate'            => p.indirect_cost_rate.to_f.to_s,
                'arms'                => [],
                'project_roles'       => [],
                'service_requests'    => [],
                'human_subjects_info' => nil
              })
            }
          )
        end
      end
    end
  end
end
