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

RSpec.describe Dashboard::ArmsController do
  describe 'delete destroy' do
    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))

      @request_params = { id: "arm id", sub_service_request_id: "sub service request id" }
      @destroyer = instance_double(Dashboard::ArmDestroyer,
        service_request: "service request",
        sub_service_request: "sub service request",
        selected_arm: "selected arm")
      allow(@destroyer).to receive(:destroy)
      allow(Dashboard::ArmDestroyer).to receive(:new).
        and_return(@destroyer)

      xhr :delete, :destroy, @request_params
    end

    it "should use Dashboard::ArmDestroyer" do
      expect(Dashboard::ArmDestroyer).to have_received(:new).
        with(id: "arm id", sub_service_request_id: "sub service request id")
    end

    it "should invoke #destroy on Dashboard::ArmDestroyer" do
      expect(@destroyer).to have_received(:destroy)
    end

    it "should assign @service_request from Dashboard::ArmDestroyer instance" do
      expect(assigns(:service_request)).to eq("service request")
    end

    it "should assign @sub_service_request from Dashboard::ArmDestroyer instance" do
      expect(assigns(:sub_service_request)).to eq("sub service request")
    end

    it "should assign @selected_arm from Dashboard::ArmDestroyer instance" do
      expect(assigns(:selected_arm)).to eq("selected arm")
    end

    it "should set flash[:alert]" do
      expect(flash[:alert]).not_to be_nil
    end

    it { is_expected.to render_template "dashboard/arms/destroy" }

    it { is_expected.to respond_with :ok }
  end
end
