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
  describe 'GET new' do
    let!(:identity) do
      findable_stub(Identity) { build_stubbed(:identity) }
    end

    let(:primary_pi) { build_stubbed(:identity) }

    let!(:protocol) do
      obj = findable_stub(Protocol) { build_stubbed(:protocol) }
      allow(obj).to receive(:primary_principal_investigator).
        and_return(primary_pi)
      obj
    end

    context "User not authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
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

        xhr :get, :new, protocol_id: protocol.id, format: :js
      end

      it 'should set @header_text to "Add Associated User"' do
        expect(assigns(:header_text)).to eq('Add Authorized User')
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end

    context 'params[:identity_id] present and unique to Protocol' do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        # stub ProjectRole creation, a little complicated
        @project_roles_association = instance_double(ActiveRecord::Relation)
        @new_project_role = build_stubbed(:project_role)
        allow(@new_project_role).to receive(:unique_to_protocol?).
          and_return(true)
        allow(protocol).to receive(:project_roles).
          and_return(@project_roles_association)
        allow(@project_roles_association).to receive(:new).
          and_return(@new_project_role)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it "should build a ProjectRole for Protocol using params[:identity_id]" do
        expect(@project_roles_association).to have_received(:new).
          with(identity_id: identity.id)
      end

      it 'should set @identity to the Identity from params[:identity_id]' do
        expect(assigns(:identity)).to eq(identity)
      end

      it 'should set @current_pi to the Primary PI of @protocol' do
        expect(assigns(:current_pi)).to eq(primary_pi)
      end

      it 'should set @project_role to a new ProjectRole associated with @protocol' do
        expect(assigns(:project_role)).to eq(@new_project_role)
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:identity_id] present and not unique to Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        # stub ProjectRole creation, a little complicated
        @project_roles_association = instance_double(ActiveRecord::Relation)
        @new_project_role = build_stubbed(:project_role)
        allow(@new_project_role).to receive(:unique_to_protocol?).and_return(false)
        allow(@new_project_role).to receive(:errors).and_return("errors")
        allow(protocol).to receive(:project_roles).
          and_return(@project_roles_association)
        allow(@project_roles_association).to receive(:new).
          and_return(@new_project_role)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it 'should set @errors' do
        expect(assigns(:errors)).to eq("errors")
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end
  end
end
