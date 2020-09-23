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
  describe 'GET /api/v1/line_items.json' do
    let!(:protocol)         { create(:protocol_federally_funded, :without_validations) }
    let!(:service_request)  { create(:service_request_without_validations, protocol: protocol) }
    let!(:service)          { create(:service_without_validations, :with_pricing_map, :with_process_ssrs_organization) }
    let!(:line_items)       { create_list(:line_item_without_validations, 5, service: service, service_request: service_request) }

    context 'with ids' do
      context 'request for :shallow records' do
        before { send_api_get_request(resource: 'line_items', ids: line_items.first(4).map(&:id), depth: 'shallow') }

        it 'should respond with an array of shallow line_items' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['line_items']).to eq(
            line_items.first(4).map{ |li| { 
              'sparc_id'      => li.id,
              'callback_url'  => li.remote_service_callback_url
            }}
          )
        end
      end

      context 'request for :full records' do
        before { send_api_get_request(resource: 'line_items', ids: line_items.first(4).map(&:id), depth: 'full') }

        it 'should respond with an array of line_items and their attributes' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['line_items']).to eq(
            line_items.first(4).map{ |li| 
              li.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at').
              merge({ 
                'sparc_id'      => li.id,
                'callback_url'  => li.remote_service_callback_url,
                'one_time_fee'  => li.one_time_fee,
                'per_unit_cost' => li.per_unit_cost
              })
            }
          )
        end
      end

      context 'request for :full_with_shallow_reflections records' do
        before { send_api_get_request(resource: 'line_items', ids: line_items.first(4).map(&:id), depth: 'full_with_shallow_reflections') }

        it 'should respond with an array of line_items and their attributes and their shallow reflections' do
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['line_items']).to eq(
            line_items.first(4).map{ |li| 
              li.attributes.
              except('id', 'created_at', 'updated_at', 'deleted_at').
              merge({
                'sparc_id'            => li.id,
                'callback_url'        => li.remote_service_callback_url,
                'one_time_fee'        => li.one_time_fee,
                'per_unit_cost'       => li.per_unit_cost,
                'line_items_visits'   => [],
                'sub_service_request' => nil,
                'service'             => {
                  'sparc_id'      => service.id,
                  'callback_url'  => service.remote_service_callback_url
                },
                'service_request' => {
                  'sparc_id'      => service_request.id,
                  'callback_url'  => service_request.remote_service_callback_url
                }
              })
            }
          )
        end
      end
    end
  end
end
