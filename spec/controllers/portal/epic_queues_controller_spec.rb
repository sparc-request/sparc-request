# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe Portal::EpicQueuesController, :type => :controller do

  let_there_be_lane
  fake_login_for_each_test
  let_there_be_j
  build_service_request_with_study
  stub_portal_controller

  let!(:identity)   { Identity.find_by_ldap_uid('jug2') }
  let!(:epic_queue) { create(:epic_queue, protocol_id: Protocol.first.id) }

  describe "GET #index" do
    it "should set epic queues" do
      session[:identity_id] = identity.id
      get(:index, format: :html)
      expect(assigns(:epic_queues).count).to eq 1
    end
  end

  describe "GET #destroy" do
    it "should delete the epic queue" do
      session[:identity_id] = identity.id
      xhr :get, :destroy, format: :js, id: epic_queue.id
      expect(response).to have_http_status(:success)
      expect { epic_queue.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
