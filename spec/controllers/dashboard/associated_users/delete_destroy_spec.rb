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
  describe 'DELETE destroy' do
    context "when not authorized" do
      before :each do
        @protocol = build_stubbed(:protocol, selected_for_epic: false)
        @protocol_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: false,
            protocol: @protocol)
        end
        allow(@protocol).to receive(:email_about_change_in_authorized_user)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :delete, :destroy, id: @protocol_role.id
      end

      it 'should not destroy @protocol_role' do
      end

      it { is_expected.not_to render_template "dashboard/associated_users/destroy" }
      it { is_expected.to respond_with :ok }
    end

    context "when authorized" do
      context "deleting the current user" do
        before :each do
          @user           = create(:identity)
          @protocol       = create(:protocol_without_validations, selected_for_epic: false, funding_status: 'funded', funding_source: 'federal')
          create(:sub_service_request, status: 'not_draft', organization: create(:organization), service_request: create(:service_request_without_validations, protocol: @protocol))
          @protocol_role  = create(:project_role, protocol: @protocol, identity: @user, project_rights: 'approve', role: 'primary-pi')

          allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)
          allow(UserMailer).to receive(:authorized_user_changed) do
            mailer = double()
            expect(mailer).to receive(:deliver)
            mailer
          end

          log_in_dashboard_identity(obj: @user)

          xhr :delete, :destroy, id: @protocol_role.id
        end

        it 'should email authorized user' do
          expect(UserMailer).to have_received(:authorized_user_changed)
        end

        it 'should destroy @protocol_role' do
          expect(ProjectRole.count).to eq(0)
        end

        it 'should set associated fields' do
          expect(assigns(:current_user_destroyed)).to eq(true)
          expect(assigns(:protocol_type)).to eq(@protocol.type)
          expect(assigns(:permission_to_edit)).to eq(false)
          expect(assigns(:admin)).to eq(false)
          expect(assigns(:return_to_dashboard)).to eq(true)
        end

        it { is_expected.to render_template "dashboard/associated_users/destroy" }
        it { is_expected.to respond_with :ok }
      end

      context "deleting a different user" do
        before :each do
          @user          = create(:identity)
          @protocol      = create(:protocol_without_validations, selected_for_epic: false, funding_status: 'funded', funding_source: 'federal')
                           create(:project_role, protocol: @protocol, identity: @user, project_rights: 'approve', role: 'primary-pi')
          @ssr = create(:sub_service_request, status: 'not_draft', organization: create(:organization), service_request: create(:service_request_without_validations, protocol: @protocol))
          @user_to_delete = create(:identity)
          @protocol_role = create(:project_role, protocol: @protocol, identity: @user_to_delete, project_rights: 'approve', role: 'consultant')

          allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)
          allow(UserMailer).to receive(:authorized_user_changed) do
            mailer = double()
            expect(mailer).to receive(:deliver)
            mailer
          end
          log_in_dashboard_identity(obj: @user)    
        end

        it 'should destroy @protocol_role' do
          xhr :delete, :destroy, id: @protocol_role.id
          expect(ProjectRole.count).to eq(1)
        end

        it 'should not set associated fields' do
          xhr :delete, :destroy, id: @protocol_role.id
          expect(assigns(:current_user_destroyed)).to eq(false)
          expect(assigns(:protocol_type)).to eq(nil)
          expect(assigns(:permission_to_edit)).to eq(nil)
          expect(assigns(:admin)).to eq(false)
          expect(assigns(:return_to_dashboard)).to eq(nil)
        end

        it 'should email authorized user' do
          xhr :delete, :destroy, id: @protocol_role.id
          expect(UserMailer).to have_received(:authorized_user_changed).twice
        end

        it 'should render appropriate template' do
          xhr :delete, :destroy, id: @protocol_role.id
          expect(response).to render_template "dashboard/associated_users/destroy"
          expect(response.status).to eq(200)
        end

        context "SSRs with status draft" do 
          it 'should not email user' do
            @ssr.update_attribute(:status, 'draft')
            xhr :delete, :destroy, id: @protocol_role.id
            expect(UserMailer).not_to have_received(:authorized_user_changed)
          end
        end
      end

      context 'USE_EPIC == true, QUEUE_EPIC == false, Protocol associated with @protocol_role is selected for epic, and @protocol_role had epic access' do
        before :each do
          @user           = create(:identity)
          @protocol       = create(:protocol_without_validations, selected_for_epic: true, funding_status: 'funded', funding_source: 'federal')
                            create(:project_role, protocol: @protocol, identity: @user, project_rights: 'approve', role: 'primary-pi')
          @protocol_role  = create(:project_role, protocol: @protocol, identity: create(:identity), project_rights: 'approve', role: 'consultant', epic_access: true)

          stub_const('USE_EPIC', true)
          stub_const('QUEUE_EPIC', false)
          
          allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal).
            with(@protocol, @protocol_role) do
              mailer = double('mail') # TODO what is the return type of #notifiy_...?
              expect(mailer).to receive(:deliver)
              mailer
            end

          log_in_dashboard_identity(obj: @user)

          xhr :delete, :destroy, id: @protocol_role.id
        end

        it "should notify Primary PI for epic user removal" do
          expect(Notifier).to have_received(:notify_primary_pi_for_epic_user_removal)
        end

        it { is_expected.to render_template "dashboard/associated_users/destroy" }
        it { is_expected.to respond_with :ok }
      end

      context "USE_EPIC == false, QUEUE_EPIC == false, Protocol associated with ProjectRole is not selected for epic, and @protocol_role did not have epic access" do
        before :each do
          @user           = create(:identity)
          @protocol       = create(:protocol_without_validations, selected_for_epic: false, funding_status: 'funded', funding_source: 'federal')
          @protocol_role  = create(:project_role, protocol: @protocol, identity: @user, project_rights: 'approve', role: 'primary-pi')

          allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

          log_in_dashboard_identity(obj: @user)

          xhr :delete, :destroy, id: @protocol_role.id    
        end

        it 'should not notify Primary PI for epic user removal' do
          expect(Notifier).not_to have_received(:notify_primary_pi_for_epic_user_removal)
        end

        it { is_expected.to render_template "dashboard/associated_users/destroy" }
        it { is_expected.to respond_with :ok }
      end
    end
  end
end