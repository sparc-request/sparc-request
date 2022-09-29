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
  describe 'GET /api/v1/human_subjects_infos.json' do
    let!(:human_subjects_infos) { create_list(:human_subjects_info_without_validations, 5) }

    context 'with ids' do
      context 'request for :shallow records' do
        before { send_api_get_request(resource: 'human_subjects_infos', ids: human_subjects_infos.first(4).map(&:id), depth: 'shallow') }

        it 'should respond with an array of shallow human_subjects_infos' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['human_subjects_infos']).to eq(
            human_subjects_infos.first(4).map{ |hsi| { 
              'sparc_id'      => hsi.id,
              'callback_url'  => hsi.remote_service_callback_url
            }}
          )
        end
      end

      context 'request for :full records' do
        before { send_api_get_request(resource: 'human_subjects_infos', ids: human_subjects_infos.first(4).map(&:id), depth: 'full') }

        it 'should respond with an array of human_subjects_infos and their attributes' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['human_subjects_infos']).to eq(
            human_subjects_infos.first(4).map{ |hsi| 
              hsi.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at').
              merge({ 
                'sparc_id'      => hsi.id,
                'callback_url'  => hsi.remote_service_callback_url
              })
            }
          )
        end
      end

      context 'request for :full_with_shallow_reflections records' do
        before { send_api_get_request(resource: 'human_subjects_infos', ids: human_subjects_infos.first(4).map(&:id), depth: 'full_with_shallow_reflections') }

        it 'should respond with an array of human_subjects_infos and their attributes and their shallow reflections' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['human_subjects_infos']).to eq(
            human_subjects_infos.first(4).map{ |hsi| 
              hsi.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at').
              merge({ 
                'sparc_id'      => hsi.id,
                'callback_url'  => hsi.remote_service_callback_url,
                'irb_records'   => [],
                'protocol'      => nil
              })
            }
          )
        end
      end
    end
  end
end
