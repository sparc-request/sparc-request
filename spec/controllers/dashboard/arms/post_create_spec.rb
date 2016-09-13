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
  describe 'post create' do
    let(:protocol) do
      findable_stub(Protocol) { build_stubbed(:protocol) }
    end

    let(:sr_stub) do
      findable_stub(ServiceRequest) { build_stubbed(:service_request) }
    end

    let(:ssr_stub) do
      findable_stub(SubServiceRequest) { build_stubbed(:sub_service_request) }
    end

    before(:each) do
      log_in_dashboard_identity(obj: build_stubbed(:identity))
    end

    context "params[:arm] does not describe a valid Arm" do
      before(:each) do
        @invalid_arm_stub = instance_double(Arm, valid?: false, errors: "MyErrors")
        @arm_builder_stub = instance_double(Dashboard::ArmBuilder, arm: @invalid_arm_stub)
        @arm_attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: -1, visit_count: "x" }
        allow(Dashboard::ArmBuilder).to receive(:new).
          and_return(@arm_builder_stub)

        xhr :post, :create, arm: @arm_attrs, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id
      end

      it "should set @errors to invalid Arm's error messages" do
        expect(assigns(:errors)).to eq("MyErrors")
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/arms/create" }
    end

    context "params[:arm] described a valid Arm" do
      before(:each) do
        @valid_arm_stub = instance_double(Arm, valid?: true)
        @arm_builder_stub = instance_double(Dashboard::ArmBuilder, arm: @valid_arm_stub)
        @arm_attrs = { protocol_id: protocol.id, name: "MyArm", subject_count: 1, visit_count: 1 }
        allow(Dashboard::ArmBuilder).to receive(:new).
          and_return(@arm_builder_stub)

        xhr :post, :create, arm: @arm_attrs, service_request_id: sr_stub.id,
          sub_service_request_id: ssr_stub.id
      end

      it "should use ArmBuilder with params[:arm] to stick new Arm in @selected_arm" do
        expect(Dashboard::ArmBuilder).to have_received(:new).with(@arm_attrs)
        expect(assigns(:selected_arm)).to eq(@valid_arm_stub)
      end

      it 'should assign @protocol from params[:arm][:protocol_id]' do
        expect(assigns(:protocol)).to eq(protocol)
      end

      it 'should assign @service_request from params[:service_request_id]' do
        expect(assigns(:service_request)).to eq(sr_stub)
      end

      it 'should assign @sub_service_request from params[:sub_service_request_id]' do
        expect(assigns(:sub_service_request)).to eq(ssr_stub)
      end

      it 'should set flash[:success]' do
        expect(flash[:success]).to eq('Arm Created!')
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/arms/create" }
    end
  end
end
