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

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET edit' do
    let!(:identity) do
      build_stubbed(:identity)
    end

    let!(:primary_pi) do
      build_stubbed(:identity)
    end

    let!(:protocol) do
      obj = build_stubbed(:protocol)
      allow(obj).to receive(:primary_principal_investigator)
        .and_return(primary_pi)
      obj
    end

    let!(:project_role) do
      obj = findable_stub(ProjectRole) do
        build_stubbed(:project_role,
          identity: identity,
          protocol: protocol)
      end
      allow(protocol).to receive(:project_roles).and_return([obj])
      obj
    end

    context "User not authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :edit, id: project_role.id, format: :js
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it { is_expected.to render_template "dashboard/shared/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :edit, id: project_role.id, format: :js
      end

      it 'should set @protocol_role from params[:id]' do
        expect(assigns(:protocol_role)).to eq(project_role)
      end

      it 'should set @protocol to Protocol of @project_role' do
        expect(assigns(:protocol)).to eq(protocol)
      end

      it 'should set @identity to the Identity associated with @project_role' do
        expect(assigns(:identity)).to eq(identity)
      end

      it 'should set @current_pi to the Primary PI of @protocol' do
        expect(assigns(:current_pi)).to eq(primary_pi)
      end

      it 'should set @header_text to "Edit Authorized User"' do
        expect(assigns(:header_text)).to eq('Edit Authorized User')
      end

      it { is_expected.to render_template "dashboard/associated_users/edit" }
      it { is_expected.to respond_with :ok }
    end
  end
end
