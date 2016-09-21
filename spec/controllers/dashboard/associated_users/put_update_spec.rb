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
  describe 'PUT update' do
    let!(:identity) { build_stubbed(:identity) }

    before(:each) { log_in_dashboard_identity(obj: identity) }

    context 'user not authorized to edit Protocol associated with ProjectRole' do
      before(:each) do
        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(identity, @protocol, can_edit: false)

        project_role = findable_stub(ProjectRole) do
          build_stubbed(:project_role, protocol: @protocol)
        end

        xhr :put, :update,  id: project_role.id, 
                            protocol_id: @protocol.id
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(@protocol, identity)
      end

      it { is_expected.to render_template "dashboard/shared/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:project_role] describes a valid update to ProjectRole with id params[:id]" do
      before(:each) do
        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(identity, @protocol, can_edit: true)

        @project_role = findable_stub(ProjectRole) do
          build_stubbed(:project_role, protocol: @protocol)
        end

        project_role_updater = instance_double(Dashboard::AssociatedUserUpdater,
          successful?: true, # valid in this context
          protocol_role: @project_role)

        allow(Dashboard::AssociatedUserUpdater).to receive(:new).
          and_return(project_role_updater)

        xhr :put, :update, id: @project_role.id, protocol_id: @protocol.id, project_role: {identity_id: '1'}
      end

      it 'should update @protocol_role using params[:project_role] using ProtocolUpdater' do
        expect(Dashboard::AssociatedUserUpdater).to have_received(:new).
          with(id: @project_role.id.to_s, project_role: {identity_id: '1'})
      end

      it 'should not set @errors' do
        expect(assigns(:errors)).to be_nil
      end

      it 'should set flash[:success]' do
        expect(flash[:success]).not_to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:project_role] describes an invalid update to ProjectRole with id params[:id]" do
      before(:each) do
        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(identity, @protocol, can_edit: true)

        @project_role = findable_stub(ProjectRole) do
          build_stubbed(:project_role, protocol: @protocol)
        end
        allow(@project_role).to receive(:errors).and_return("my errors")

        @project_role_updater = instance_double(Dashboard::AssociatedUserUpdater,
          successful?: false, # valid in this context
          protocol_role: @project_role)

        allow(Dashboard::AssociatedUserUpdater).to receive(:new).and_return(@project_role_updater)

        xhr :put, :update, id: @project_role.id, protocol_id: @protocol.id, project_role: {identity_id: '1'}
      end

      it 'should set @errors' do
        expect(assigns(:errors)).to eq("my errors")
      end

      it 'should not set flash[:success]' do
        expect(flash[:success]).to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/update" }
      it { is_expected.to respond_with :ok }
    end
  end
end
