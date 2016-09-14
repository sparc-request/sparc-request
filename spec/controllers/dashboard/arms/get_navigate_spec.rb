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
  describe 'GET navigate' do
    let(:protocol_stub) do
      findable_stub(Protocol) do
        instance_double(Protocol,
          id: 1,
          arms: [build_stubbed(:arm), build_stubbed(:arm)])
      end
    end

    let(:arm_stub) do
      findable_stub(Arm) { build_stubbed(:arm) }
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

    context 'params[:arm_id] present' do
      before(:each) do
        xhr :get, :navigate, protocol_id: protocol_stub.id, arm_id: arm_stub.id,
          service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id,
          intended_action: 'chillax'
      end

      it 'should set @protocol from params[:protocol_id]' do
        expect(assigns(:protocol)).to eq(protocol_stub)
      end

      it 'should set @service_request from params[:service_request_id]' do
        expect(assigns(:service_request)).to eq(sr_stub)
      end

      it 'should set @sub_service_request from params[:sub_service_request_id]' do
        expect(assigns(:sub_service_request)).to eq(ssr_stub)
      end

      it 'should set @intended_action to params[:intended_action]' do
        expect(assigns(:intended_action)).to eq('chillax')
      end

      it 'should set @arm from params[:arm_id]' do
        expect(assigns(:arm)).to eq(arm_stub)
      end

      it { is_expected.to render_template "dashboard/arms/navigate" }
      it { is_expected.to respond_with :ok }
    end

    context 'params[:arm_id] absent' do
      before(:each) do
        xhr :get, :navigate, protocol_id: protocol_stub.id, service_request_id: sr_stub.id, sub_service_request_id: ssr_stub.id, intended_action: 'chillax'
      end

      it 'should set @arm to the Protocol\'s first Arm' do
        expect(assigns(:arm)).to eq(protocol_stub.arms.first)
      end

      it 'should set @protocol from params[:protocol_id]' do
        expect(assigns(:protocol)).to eq(protocol_stub)
      end

      it 'should set @service_request from params[:service_request_id]' do
        expect(assigns(:service_request)).to eq(sr_stub)
      end

      it 'should set @sub_service_request from params[:sub_service_request_id]' do
        expect(assigns(:sub_service_request)).to eq(ssr_stub)
      end

      it 'should set @intended_action to params[:intended_action]' do
        expect(assigns(:intended_action)).to eq('chillax')
      end

      it { is_expected.to render_template "dashboard/arms/navigate" }
      it { is_expected.to respond_with :ok }
    end
  end
end
