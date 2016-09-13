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

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #new' do
    context 'params[:protocol_type] == "project"' do
      before(:each) do
        @current_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @current_user)
        get :new, protocol_type: 'project'
      end

      it 'should set @protocol_type to "project"' do
        expect(assigns(:protocol_type)).to eq('project')
      end

      it 'should set @protocol to a new Project with requester equal to logged in user' do
        expect(assigns(:protocol).class.name).to eq('Project')
        expect(assigns(:protocol).id).to eq(nil)
        expect(assigns(:protocol).requester_id).to eq(@current_user.id)
      end

      it 'should set session[:protocol_type] to "project"' do
        expect(session[:protocol_type]).to eq('project')
      end

      it { is_expected.to render_template "dashboard/protocols/new" }
      it { is_expected.to respond_with :ok }
    end

    context 'params[:protocol_type] == "study"' do
      before(:each) do
        @current_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @current_user)
        get :new, protocol_type: 'study'
      end

      it 'should set @protocol_type to "study"' do
        expect(assigns(:protocol_type)).to eq('study')
      end

      it 'should set @protocol to a new Study with requester equal to logged in user' do
        expect(assigns(:protocol).class.name).to eq('Study')
        expect(assigns(:protocol).id).to eq(nil)
        expect(assigns(:protocol).requester_id).to eq(@current_user.id)
      end

      it 'should set session[:protocol_type] to "study"' do
        expect(session[:protocol_type]).to eq('study')
      end

      it { is_expected.to render_template "dashboard/protocols/new" }
      it { is_expected.to respond_with :ok }
    end
  end
end
