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
  describe 'GET new' do
    let!(:identity_stub) { build_stubbed(:identity) }

    let!(:protocol_stub) do
      findable_stub(Protocol) { build_stubbed(:protocol) }
    end

    let!(:sr_stub) do
      findable_stub(ServiceRequest) { build_stubbed(:service_request) }
    end

    let!(:ssr_stub) do
      findable_stub(SubServiceRequest) { build_stubbed(:sub_service_request) }
    end

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
      xhr :get, :new, protocol_id: protocol_stub.id, service_request_id: sr_stub.id,
        sub_service_request_id: ssr_stub.id, schedule_tab: 'schedule_tab'
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

    it 'should set @schedule_tab from params[:schedule_tab]' do
      expect(assigns(:schedule_tab)).to eq('schedule_tab')
    end

    it 'should assign @arm to a new, unpersisted Arm associated with Protocol' do
      expect(assigns(:arm).protocol_id).to eq(protocol_stub.id)
      expect(assigns(:arm)).not_to be_persisted
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template "dashboard/arms/new" }
  end
end
