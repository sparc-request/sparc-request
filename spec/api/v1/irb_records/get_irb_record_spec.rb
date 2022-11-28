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
  describe 'GET /api/v1/irb_record/:id.json' do
    let!(:irb_record) { irb = create(:irb_record_without_validations)}

    context 'request for :shallow record' do
      before { send_api_get_request(resource: 'irb_records', id: irb_record.id, depth: 'shallow') }

      it 'should respond with a shallow irb_record' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['irb_record']).to eq({
          'sparc_id'      => irb_record.id,
          'callback_url'  => irb_record.remote_service_callback_url
        })
      end
    end

    context 'request for :full record' do
      before { send_api_get_request(resource: 'irb_records', id: irb_record.id, depth: 'full') }

      it 'should respond with an irb_record and its attributes' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['irb_record']).to eq(
          irb_record.attributes.
          except('id', 'created_at', 'updated_at', 'deleted_at').
          merge({
            'sparc_id'                  => irb_record.id,
            'callback_url'              => irb_record.remote_service_callback_url,
            'initial_irb_approval_date' => irb_record.initial_irb_approval_date.to_s(:db),
            'irb_approval_date'         => irb_record.irb_approval_date.to_s(:db),
            'irb_expiration_date'       => irb_record.irb_expiration_date.to_s(:db),
            'study_phase_values'        => []
          })
        )
      end
    end

    context 'request for :full_with_shallow_reflections record' do
      before { send_api_get_request(resource: 'irb_records', id: irb_record.id, depth: 'full_with_shallow_reflections') }

      it 'should respond with an irb_record and its attributes and its shallow reflections' do
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['irb_record']).to eq(
          irb_record.attributes.
          except('id', 'created_at', 'updated_at', 'deleted_at').
          merge({
            'sparc_id'                  => irb_record.id,
            'callback_url'              => irb_record.remote_service_callback_url,
            'initial_irb_approval_date' => irb_record.initial_irb_approval_date.to_s(:db),
            'irb_approval_date'         => irb_record.irb_approval_date.to_s(:db),
            'irb_expiration_date'       => irb_record.irb_expiration_date.to_s(:db),
            'study_phase_values'        => [],
            'human_subjects_info'       => nil
          })
        )
      end
    end
  end
end
