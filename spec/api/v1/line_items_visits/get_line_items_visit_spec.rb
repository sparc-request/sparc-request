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
  describe 'GET /api/v1/line_items_visit/:id.json' do
    let!(:line_items_visit) { create(:line_items_visit_without_validations) }

    context 'request for :shallow record' do
      before { send_api_get_request(resource: 'line_items_visits', id: line_items_visit.id, depth: 'shallow') }

      it 'should respond with a shallow line_items_visit' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['line_items_visit']).to eq({
          'sparc_id'      => line_items_visit.id,
          'callback_url'  => line_items_visit.remote_service_callback_url
        })
      end
    end

    context 'request for :full record' do
      before { send_api_get_request(resource: 'line_items_visits', id: line_items_visit.id, depth: 'full') }

      it 'should respond with an line_items_visit and its attributes' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['line_items_visit']).to eq(
          line_items_visit.attributes.
          except('id', 'created_at', 'updated_at', 'deleted_at').
          merge({
            'sparc_id'      => line_items_visit.id,
            'callback_url'  => line_items_visit.remote_service_callback_url
          })
        )
      end
    end

    context 'request for :full_with_shallow_reflections record' do
      before { send_api_get_request(resource: 'line_items_visits', id: line_items_visit.id, depth: 'full_with_shallow_reflections') }

      it 'should respond with an line_items_visit and its attributes and its shallow reflections' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['line_items_visit']).to eq(
          line_items_visit.attributes.
          except('id', 'created_at', 'updated_at', 'deleted_at').
          merge({
            'sparc_id'      => line_items_visit.id,
            'callback_url'  => line_items_visit.remote_service_callback_url,
            'visits'        => [],
            'line_item'     => nil,
            'arm'           => nil
          })
        )
      end
    end
  end
end
