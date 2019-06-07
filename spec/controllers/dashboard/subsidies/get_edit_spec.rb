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

RSpec.describe Dashboard::SubsidiesController do
  describe 'GET #edit' do
    before(:each) do
      @current_user = build_stubbed(:identity)
      log_in_dashboard_identity(obj: @current_user)
      @protocol        = create(:protocol_without_validations,
                                primary_pi: @current_user)
      @organization    = create(:organization)
      @subsidy_map     = create(:subsidy_map,
                                default_percentage: 5,
                                organization: @organization)
      @service_request = create(:service_request_without_validations,
                                protocol: @protocol)
      @ssr             = create(:sub_service_request_without_validations,
                                service_request: @service_request,
                                organization: @organization,
                                status: 'draft')
      @pending_subsidy = create(:pending_subsidy,
                                sub_service_request_id: @ssr.id,
                                percent_subsidy: 0.1)
      get :edit, params: { admin: 'true', id: @pending_subsidy.id, format: :js }, xhr: true
    end

    it { is_expected.to render_template "dashboard/subsidies/edit" }

    it 'should respond ok' do
      expect(controller).to respond_with(:ok)
    end

    it 'should set @admin to params[:admin]' do
      expect(assigns(:admin)).to eq(true)
    end

    it 'should set @subsidy to the existing PendingSubsidy' do
      expect(assigns(:subsidy)).to eq(PendingSubsidy.find(@pending_subsidy.id))
    end

    it 'should set @path to the dashboard subsidy path for @subsidy' do
      expect(assigns(:path)).to eq(dashboard_subsidy_path(assigns(:subsidy)))
    end

    it 'should assign header text' do
      expect(assigns(:header_text)).to be
    end

    it 'should assign @action to edit' do
      expect(assigns(:action)).to eq('edit')
    end
  end
end