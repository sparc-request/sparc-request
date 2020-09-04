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
  describe 'PUT /api/v1/service/:id.json' do
    let!(:service) { create(:service_without_validations, :with_pricing_map, :with_process_ssrs_organization) }

    context "success" do
      context "increment" do
        before { send_api_update_request(resource: 'services', id: service.id, params: { service: { line_items_count: 1 } }) }

        it "should increment the Service.line_items_count" do
          expect(response.status).to eq(200)
          expect(service.reload.line_items_count).to eq(1)
        end
      end

      context "decrement" do
        before { send_api_update_request(resource: 'services', id: service.id, params: { service: { line_items_count: -1 } }) }

        it "should decrement the Service.line_items_count" do
          expect(response.status).to eq(200)
          expect(service.reload.line_items_count).to eq(0)
        end
      end
    end

    context "failure" do
      context "params[:service][:line_items_count] not present" do
        before { send_api_update_request(resource: 'services', id: service.id, params: { service: {}}) }

        it 'should respond with an HTTP status code of: 400' do
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
