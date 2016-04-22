require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET show' do
    let!(:identity) do
      obj = instance_double(Identity, id: 1)
      stub_find_identity(obj)
      obj
    end

    let!(:protocol) do
      obj = instance_double(Protocol, id: 2)
      stub_find_protocol(obj)
      obj
    end

    let!(:project_role) do
      obj = instance_double(ProjectRole,
        id: 3,
        identity: identity,
        protocol: protocol)
      stub_find_project_role(obj)

      # associate this ProjectRole with protocol via #find_by
      project_roles_collection = instance_double(ActiveRecord::Relation)
      allow(project_roles_collection).to receive(:find_by).
        with(identity_id: identity.id).
        and_return(obj)
      allow(protocol).to receive(:project_roles).and_return(project_roles_collection)
      obj
    end

    context "User not authorized to view Protocol" do
      render_views

      before(:each) do
        authorize(identity, protocol, can_view: false)
        log_in_dashboard_identity(obj: identity)

        get :show, id: identity.id, protocol_id: protocol.id, format: :js
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to view Protocol" do
      render_views

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

    def authorize(identity, protocol, opts = {})
      auth_mock = instance_double('ProtocolAuthorizer',
        'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
        'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
      expect(ProtocolAuthorizer).to receive(:new).
        with(protocol, identity).
        and_return(auth_mock)
    end

    def stub_find_protocol(protocol_stub)
      allow(Protocol).to receive(:find).
        with(protocol_stub.id).
        and_return(protocol_stub)
    end

    def stub_find_project_role(obj)
      allow(ProjectRole).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
    end

    def stub_find_identity(obj)
      allow(Identity).to receive(:find).
        with(obj.id.to_s).
        and_return(obj)
    end
  end
end
