require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'DELETE destroy' do
    context "deleting the current user" do
      before :each do
        @user           = build_stubbed(:identity)
        @protocol       = build_stubbed(:protocol, selected_for_epic: false)
        @protocol_role  = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: false,
            protocol: @protocol
          )
        end

        allow(@protocol_role).to receive(:destroy)
        allow(@protocol_role).to receive(:clone).and_return(@protocol_role)
        allow(@protocol_role).to receive(:identity_id).and_return(@user.id)

        allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

        log_in_dashboard_identity(obj: @user)

        xhr :delete, :destroy, id: @protocol_role.id
      end

      it 'should destroy @protocol_role' do
        expect(@protocol_role).to have_received(:destroy)
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
        @protocol      = build_stubbed(:protocol, selected_for_epic: false)
        @protocol_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: false,
            protocol: @protocol
          )
        end

        allow(@protocol_role).to receive(:destroy)
        allow(@protocol_role).to receive(:clone).and_return(@protocol_role)
        allow(@protocol_role).to receive(:identity_id).and_return(0)

        allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :delete, :destroy, id: @protocol_role.id
      end

      it 'should destroy @protocol_role' do
        expect(@protocol_role).to have_received(:destroy)
      end

      it 'should not set associated fields' do
        expect(assigns(:current_user_destroyed)).to eq(false)
        expect(assigns(:protocol_type)).to eq(nil)
        expect(assigns(:permission_to_edit)).to eq(nil)
        expect(assigns(:admin)).to eq(nil)
        expect(assigns(:return_to_dashboard)).to eq(nil)
      end

      it { is_expected.to render_template "dashboard/associated_users/destroy" }
      it { is_expected.to respond_with :ok }
    end

    context 'USE_EPIC == true, QUEUE_EPIC == false, Protocol associated with @protocol_role is selected for epic, and @protocol_role had epic access' do
      before :each do
        @protocol      = build_stubbed(:protocol, selected_for_epic: true)
        @protocol_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: true,
            protocol: @protocol
          )
        end

        stub_const('USE_EPIC', true)
        stub_const('QUEUE_EPIC', false)

        allow(@protocol_role).to receive(:destroy)
        allow(@protocol_role).to receive(:clone).and_return(@protocol_role)
        allow(@protocol_role).to receive(:identity_id).and_return(0)
        
        allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal).
          with(@protocol, @protocol_role) do
            mailer = double('mail') # TODO what is the return type of #notifiy_...?
            expect(mailer).to receive(:deliver)
            mailer
          end

        log_in_dashboard_identity(obj: build_stubbed(:identity))

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
        @protocol_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: false,
            protocol: build_stubbed(:protocol, selected_for_epic: false))
        end

        allow(@protocol_role).to receive(:destroy)
        allow(@protocol_role).to receive(:clone).and_return(@protocol_role)
        allow(@protocol_role).to receive(:identity_id).and_return(0)

        allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

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
