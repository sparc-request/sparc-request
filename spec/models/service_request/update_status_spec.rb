# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.describe ServiceRequest, type: :model do
  let_there_be_lane
  let_there_be_j

  describe "#update_status" do

    context "new_status == 'submitted'" do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        identity     = create(:identity)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr_not_previously_submitted   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil, protocol: protocol)
        @ssr_previously_submitted   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: Time.now.utc, protocol: protocol)
      end

      it "should return the id of the ssr that was not previously submitted" do
        @sr.reload
        expect(@sr.update_status('submitted')).to eq([@ssr_not_previously_submitted.id])
      end
    end

    context "new_status == 'get_a_cost_estimate'" do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        identity     = create(:identity)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: identity, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr_not_previously_submitted   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil, protocol: protocol)
        @ssr_previously_submitted   = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: Time.now.utc, protocol: protocol)
      end

      it "should return the ids of all the ssrs" do
        @sr.reload
        expect(@sr.update_status('get_a_cost_estimate')).to eq(@sr.sub_service_requests.map(&:id))
      end
    end
  end
end
