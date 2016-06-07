require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'DELETE destroy' do
    context "when not authorized" do
      before :each do
        @protocol_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: false,
            protocol: build_stubbed(:protocol, selected_for_epic: false))
        end
        
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
          @protocol_role  = create(:project_role, protocol: @protocol, identity: @user, project_rights: 'approve', role: 'primary-pi')

          allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

          log_in_dashboard_identity(obj: @user)

          xhr :delete, :destroy, id: @protocol_role.id
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
          @protocol_role = create(:project_role, protocol: @protocol, identity: create(:identity), project_rights: 'approve', role: 'consultant')

          allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

          log_in_dashboard_identity(obj: @user)

          xhr :delete, :destroy, id: @protocol_role.id
        end

        it 'should destroy @protocol_role' do
          expect(ProjectRole.count).to eq(1)
        end

        it 'should not set associated fields' do
          expect(assigns(:current_user_destroyed)).to eq(false)
          expect(assigns(:protocol_type)).to eq(nil)
          expect(assigns(:permission_to_edit)).to eq(nil)
          expect(assigns(:admin)).to eq(false)
          expect(assigns(:return_to_dashboard)).to eq(nil)
        end

        it { is_expected.to render_template "dashboard/associated_users/destroy" }
        it { is_expected.to respond_with :ok }
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
