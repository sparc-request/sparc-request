require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET show' do
    let!(:identity) do
      findable_stub(Identity) { build_stubbed(:identity) }
    end

    let!(:protocol) do
      findable_stub(Protocol) { build_stubbed(:protocol) }
    end

    let!(:project_role) do
      obj = findable_stub(ProjectRole) do
        build_stubbed(:project_role, identity: identity, protocol: protocol)
      end

      # also associate this ProjectRole with protocol via #find_by
      project_roles_association = instance_double(ActiveRecord::Relation)
      allow(project_roles_association).to receive(:find_by).
        with(identity_id: identity.id).
        and_return(obj)
      allow(protocol).to receive(:project_roles).and_return(project_roles_association)
      obj
    end

    context "User not authorized to view Protocol" do
      before(:each) do
        authorize(identity, protocol, can_view: false)
        log_in_dashboard_identity(obj: identity)

        get :show, id: identity.id, protocol_id: protocol.id, format: :js
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to view Protocol" do
      before(:each) do
        authorize(identity, protocol, can_view: true)
        log_in_dashboard_identity(obj: identity)

        get :show, id: identity.id, protocol_id: protocol.id, format: :js
      end

      it 'should set @user from params[:id]' do
        expect(assigns(:user)).to eq(identity)
      end

      it "should set @protocol from params[:protocol_id]" do
        expect(assigns(:protocol)).to eq(protocol)
      end

      it { is_expected.to render_template nil }
      it { is_expected.to respond_with :ok }
    end
  end
end
