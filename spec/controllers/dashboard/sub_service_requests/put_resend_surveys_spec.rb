# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe Dashboard::SubServiceRequestsController do
  
  describe '#resend_surveys' do
    before :each do
      logged_in_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: logged_in_user)

      org = build_stubbed(:organization)

      allow(logged_in_user).to receive(:authorized_admin_organizations).and_return([org])

      @ssr = findable_stub(SubServiceRequest) do
        build_stubbed(:sub_service_request, organization: org)
      end

      allow(@ssr).to receive(:distribute_surveys).and_return(true)
    end

    context 'surveys have already been completed' do
      before :each do
        allow(@ssr).to receive(:surveys_completed?).and_return(true)

        put :resend_surveys, params: { id: @ssr.id, format: :js }, xhr: true
      end
      
      it 'should not distribute surveys' do
        expect_any_instance_of(SubServiceRequest).to_not receive(:distribute_surveys)
      end
    end

    context 'surveys are pending' do
      before :each do
        allow(@ssr).to receive(:surveys_completed?).and_return(false)

        put :resend_surveys, params: { id: @ssr.id, format: :js }, xhr: true
      end

      it 'should distribute surveys' do
        expect(@ssr).to have_received(:distribute_surveys)
      end
    end
  end
end
