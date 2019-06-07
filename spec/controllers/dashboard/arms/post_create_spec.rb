# Copyright © 2011-2019 MUSC Foundation for Research Development~
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
  describe 'post create' do
    before :each do
      log_in_dashboard_identity(obj: build_stubbed(:identity))

      @organization = create(:organization)
      @protocol     = create(:study_without_validations)
      @sr           = create(:service_request_without_validations, protocol: @protocol)
      @ssr          = create(:sub_service_request_without_validations, service_request: @sr, organization: @organization)
    end

    context "params[:arm] does not describe a valid Arm" do
      before(:each) do
        @arm_params = { protocol_id: @protocol.id, name: "MyArm", subject_count: -1, visit_count: "x" }

        post :create, params: {
          arm: @arm_params,
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id
        }, xhr: true
      end

      it "should not create an arm" do
        expect(Arm.count).to eq(0)
      end

      it "should set @errors to invalid Arm's error messages" do
        expect(assigns(:errors)).to be
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/arms/create" }
    end

    context "params[:arm] described a valid Arm" do
      before(:each) do
        @arm_params = { protocol_id: @protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }

        post :create, params: {
          arm: @arm_params,
          service_request_id: @sr.id,
          sub_service_request_id: @ssr.id,
          protocol_id: @protocol.id
        }, xhr: true
      end

      it "should create an arm" do
        expect(assigns(:selected_arm)).to be_a(Arm)
      end

      it 'should assign @protocol from params[:arm][:protocol_id]' do
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it 'should assign @service_request from params[:service_request_id]' do
        expect(assigns(:service_request)).to eq(@sr)
      end

      it 'should assign @sub_service_request from params[:sub_service_request_id]' do
        expect(assigns(:sub_service_request)).to eq(@ssr)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/arms/create" }
    end
  end
end
