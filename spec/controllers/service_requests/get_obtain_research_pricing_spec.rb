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

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  let!(:org)      { create(:organization) }
  let!(:service)  { create(:service, organization: org, one_time_fee: true) }
  let!(:protocol) { create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study') }
  let!(:sr)       { create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-02-10') }
  let!(:ssr)      { create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id) }
  let!(:li)       { create(:line_item, service_request: sr, sub_service_request: ssr, service: service) }

  before :each do
    session[:identity_id] = logged_in_user.id
  end

  describe '#obtain_research_pricing' do
    it 'should call the Notifier Logic to update the request' do
      expect(NotifierLogic).to receive_message_chain(:delay, :obtain_research_pricing_logic)

      get :obtain_research_pricing, params: { srid: sr.id }, xhr: true

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    it 'should render confirmation' do
      get :obtain_research_pricing, params: { srid: sr.id }, xhr: true

      expect(controller).to render_template(:confirmation)
    end
  end
end
