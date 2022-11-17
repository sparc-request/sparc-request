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
  describe 'GET /api/v1/clinical_providers.json' do
    let!(:clinical_providers) { create_list(:clinical_provider_without_validations, 5) }

    context 'request for :shallow records' do
      before { send_api_get_request(resource: 'clinical_providers', depth: 'shallow') }

      it 'should respond with an array of shallow clinical_providers' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['clinical_providers']).to eq(
          clinical_providers.map{ |cp| { 
            'sparc_id'      => cp.id,
            'callback_url'  => cp.remote_service_callback_url
          }}
        )
      end
    end

    context 'request for :full records' do
      before { send_api_get_request(resource: 'clinical_providers', depth: 'full') }

      it 'should respond with an array of clinical_providers and their attributes' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['clinical_providers']).to eq(
          clinical_providers.map{ |cp| 
            cp.attributes.
            except('id', 'created_at', 'updated_at', 'deleted_at').
            merge({ 
              'sparc_id'      => cp.id,
              'callback_url'  => cp.remote_service_callback_url
            })
          }
        )
      end
    end

    context 'request for :full_with_shallow_reflections records' do
      before { send_api_get_request(resource: 'clinical_providers', depth: 'full_with_shallow_reflections') }

      it 'should respond with an array of clinical_providers and their attributes and their shallow reflections' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['clinical_providers']).to eq(
          clinical_providers.map{ |cp| 
            cp.attributes.
            except('id', 'created_at', 'updated_at', 'deleted_at').
            merge({ 
              'sparc_id'      => cp.id,
              'callback_url'  => cp.remote_service_callback_url,
              'identity'      => nil,
              'organization'  => nil
            })
          }
        )
      end
    end
  end
end
