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
  describe 'POST create' do
    let!(:identity)   { build_stubbed(:identity) }
    let!(:other_user) { build_stubbed(:identity) }
    let!(:protocol)   { findable_stub(Protocol) { build_stubbed(:protocol) } }

    context "User not authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :post, :create, protocol_id: protocol.id, format: :js
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it { is_expected.to render_template "dashboard/shared/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol and params[:project_role] describes valid ProjectRole" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs = {identity_id: other_user.id}
        associated_user_creator = instance_double(Dashboard::AssociatedUserCreator,
          successful?: true)
        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)

        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it "should use Dashboard::AssociatedUserCreator to create ProjectRole" do
        expect(Dashboard::AssociatedUserCreator).to have_received(:new).
          with(@new_project_roles_attrs)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol and params[:project_role] describes an invalid ProjectRole" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs = {identity_id: other_user.id}
        new_project_role = build_stubbed(:project_role)
        allow(new_project_role).to receive(:errors).and_return("my errors")
        associated_user_creator = instance_double(Dashboard::AssociatedUserCreator,
          successful?: false,
          protocol_role: new_project_role)

        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)

        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it "should use Dashboard::AssociatedUserCreator to (attempt) to create ProjectRole" do
        expect(Dashboard::AssociatedUserCreator).to have_received(:new).
          with(@new_project_roles_attrs)
      end

      it "should set @errors from built ProjectRole's errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
      it { is_expected.to respond_with :ok }
    end

    context "admin user adds themself to a protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs  = {identity_id: identity.id}
        project_role              = instance_double(ProjectRole, can_edit?: true, can_view?: true)
        associated_user_creator   = instance_double(Dashboard::AssociatedUserCreator,
          successful?: true)

        allow(associated_user_creator).to receive(:protocol_role).
          and_return(project_role)
        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)
        
        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it 'should set @permission_to_edit' do
        expect(assigns(:permission_to_edit)).to eq(true)
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
