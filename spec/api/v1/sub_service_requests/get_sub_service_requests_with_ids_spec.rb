# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

  describe 'GET /v1/sub_service_requests.json' do

    before do
      5.times do
        organization        = create(:organization)
        sub_service_request = create(:sub_service_request, organization: organization)
      end

      @sub_service_request_ids = SubServiceRequest.pluck(:id)
    end

    context 'with ids' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'shallow', @sub_service_request_ids.pop(4)) }

      context 'success' do

        it 'should respond with an HTTP status code of: 200' do
          expect(response.status).to eq(200)
        end

        it 'should respond with content-type: application/json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'should respond with a SubServiceRequests root object' do
          expect(response.body).to include('"sub_service_requests":')
        end

        it 'should respond with an array of SubServiceRequests' do
          parsed_body = JSON.parse(response.body)

          expect(parsed_body['sub_service_requests'].length).to eq(4)
        end
      end
    end

    context 'request for :shallow records' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'shallow', @sub_service_request_ids) }

      it 'should respond with an array of :sparc_ids' do
        parsed_body = JSON.parse(response.body)

        expect(parsed_body['sub_service_requests'].map(&:keys).flatten.uniq.sort).to eq(['sparc_id', 'callback_url'].sort)
      end
    end

    context 'request for :full records' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'full', @sub_service_request_ids) }

      it 'should respond with an array of sub_service_requests and their attributes' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:sub_service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'submitted_at', 'protocol_id'].include?(key) }.
                                push('callback_url', 'sparc_id', 'grand_total').
                                sort

        expect(parsed_body['sub_service_requests'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end

    context 'request for :full_with_shallow_reflections records' do

      before { cwf_sends_api_get_request_for_resources('sub_service_requests', 'full_with_shallow_reflections', @sub_service_request_ids) }

      it 'should respond with an array of sub_service_requests and their attributes and their shallow reflections' do
        parsed_body         = JSON.parse(response.body)
        expected_attributes = build(:sub_service_request).attributes.
                                keys.
                                reject { |key| ['id', 'created_at', 'updated_at', 'deleted_at', 'submitted_at', 'protocol_id'].include?(key) }.
                                push('callback_url', 'sparc_id', 'line_items', 'service_request', 'grand_total').
                                sort

        expect(parsed_body['sub_service_requests'].map(&:keys).flatten.uniq.sort).to eq(expected_attributes)
      end
    end
  end
end
