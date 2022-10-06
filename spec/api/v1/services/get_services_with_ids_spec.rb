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
  describe 'GET /api/v1/services.json' do
    let!(:services) { create_list(:service_without_validations, 5, :with_pricing_map, :with_process_ssrs_organization).sort_by(&:order) }

    context 'with ids' do
      context 'request for :shallow records' do
        before { send_api_get_request(resource: 'services', ids: services.first(4).map(&:id), depth: 'shallow') }

        it 'should respond with an array of shallow services' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['services']).to eq(
            services.first(4).map{ |s| { 
              'sparc_id'      => s.id,
              'callback_url'  => s.remote_service_callback_url
            }}
          )
        end
      end

      context 'request for :full records' do
        before { send_api_get_request(resource: 'services', ids: services.first(4).map(&:id), depth: 'full') }

        it 'should respond with an array of services and their attributes' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['services']).to eq(
            services.first(4).map{ |s| 
              s.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at', 'order_code', 'tag_list').
              merge({ 
                'sparc_id'                  => s.id,
                'callback_url'              => s.remote_service_callback_url,
                'direct_link'               => s.direct_link,
                'service_center_cost'       => s.service_center_cost.to_f.to_s,
                'process_ssrs_organization' => {
                  'sparc_id'      => s.process_ssrs_organization.id,
                  'name'          => s.process_ssrs_organization.name,
                  'callback_url'  => s.process_ssrs_organization.remote_service_callback_url,
                }
              })
            }
          )
        end
      end

      context 'request for :full_with_shallow_reflections records' do
        before { send_api_get_request(resource: 'services', ids: services.first(4).map(&:id), depth: 'full_with_shallow_reflections') }

        it 'should respond with an array of services and their attributes and their shallow reflections' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['services']).to eq(
            services.first(4).map{ |s| 
              s.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at', 'order_code', 'tag_list').
              merge({
                'sparc_id'                  => s.id,
                'callback_url'              => s.remote_service_callback_url,
                'direct_link'               => s.direct_link,
                'service_center_cost'       => s.service_center_cost.to_f.to_s,
                'line_items'                => [],
                'process_ssrs_organization' => {
                  'sparc_id'      => s.process_ssrs_organization.id,
                  'name'          => s.process_ssrs_organization.name,
                  'callback_url'  => s.process_ssrs_organization.remote_service_callback_url,
                }
              })
            }
          )
        end
      end
    end
  end
end
