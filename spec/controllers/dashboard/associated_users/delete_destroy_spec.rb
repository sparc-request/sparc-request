require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'DELETE destroy' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    it 'should set @project_role from params[:id]' do
      pr = instance_double('ProjectRole',
        id: 1,
        destroy: true,
        epic_access: false,
        clone: :clone,
        protocol: instance_double('Protocol',
          selected_for_epic: false))
      stub_find_project_role(pr)

      xhr :delete, :destroy, id: pr.id

      expect(assigns(:protocol_role)).to eq(pr)
    end

    it 'should destroy @project_role' do
      pr = instance_double('ProjectRole',
        id: 1,
        epic_access: false,
        clone: :clone,
        protocol: instance_double('Protocol',
          selected_for_epic: false))
      expect(pr).to receive(:destroy)
      stub_find_project_role(pr)

      xhr :delete, :destroy, id: pr.id

      expect(assigns(:protocol_role)).to eq(pr)
    end

    context 'USE_EPIC == true, QUEUE_EPIC == false, Protocol associated with @project_role is selected for epic, and @project_role had epic access' do
      it 'should notify Primary PI for epic user removal' do
        stub_const('USE_EPIC', true)
        stub_const('QUEUE_EPIC', false)

        protocol = instance_double('Protocol',
          selected_for_epic: true)

        pr = instance_double('ProjectRole',
          id: 1,
          epic_access: true,
          destroy: true,
          protocol: protocol)
        allow(pr).to receive(:clone).and_return(pr)
        stub_find_project_role(pr)

        expect(Notifier).to receive(:notify_primary_pi_for_epic_user_removal).with(protocol, pr) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        xhr :delete, :destroy, id: pr.id
      end
    end

    def stub_find_project_role(pr)
      allow(ProjectRole).to receive(:find).with(pr.id.to_s).and_return(pr)
    end
  end
end
