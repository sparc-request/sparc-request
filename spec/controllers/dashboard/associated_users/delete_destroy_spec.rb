require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'DELETE destroy' do
    # TODO what are typical contexts (concerning the conditions below)?
    # Won't exhaustively test each possible one...
    context "USE_EPIC == false, QUEUE_EPIC == false, Protocol associated with ProjectRole is not selected for epic, and @project_role did not have epic access" do
      before(:each) do
        @project_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: false,
            clone: :clone,
            protocol: build_stubbed(:protocol, selected_for_epic: false))
        end
        allow(@project_role).to receive(:destroy)

        allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal)

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :delete, :destroy, id: @project_role.id
      end

      it 'should destroy @project_role' do
        expect(@project_role).to have_received(:destroy)
      end

      it "should not notify Primary PI for epic user removal" do
        expect(Notifier).not_to have_received(:notify_primary_pi_for_epic_user_removal)
      end

      it { is_expected.to render_template "dashboard/associated_users/destroy" }
      it { is_expected.to respond_with :ok }
    end

    context 'USE_EPIC == true, QUEUE_EPIC == false, Protocol associated with @project_role is selected for epic, and @project_role had epic access' do
      before(:each) do
        protocol = instance_double(Protocol,
          selected_for_epic: true)

        @project_role = findable_stub(ProjectRole) do
          instance_double(ProjectRole,
            id: 1,
            epic_access: true,
            destroy: true,
            protocol: protocol)
        end
        allow(@project_role).to receive(:clone).and_return(@project_role)

        stub_const('USE_EPIC', true)
        stub_const('QUEUE_EPIC', false)

        allow(Notifier).to receive(:notify_primary_pi_for_epic_user_removal).
          with(protocol, @project_role) do
            mailer = double('mail') # TODO what is the return type of #notifiy_...?
            expect(mailer).to receive(:deliver)
            mailer
          end

        log_in_dashboard_identity(obj: build_stubbed(:identity))

        xhr :delete, :destroy, id: @project_role.id
      end

      it 'should destroy @project_role' do
        expect(@project_role).to have_received(:destroy)
      end

      it 'should notify Primary PI for epic user removal' do
        expect(Notifier).to have_received(:notify_primary_pi_for_epic_user_removal)
      end

      it { is_expected.to render_template "dashboard/associated_users/destroy" }
      it { is_expected.to respond_with :ok }
    end
  end
end
