require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET index' do
    let!(:identity) do
      build_stubbed(:identity)
    end

    let!(:protocol) do
      obj = build_stubbed(:protocol)
      stub_find_protocol(obj)
      obj
    end

    context "User does not have view rights to Protocol" do
      render_views
      before(:each) do
        authorize(identity, protocol, can_view: false)
        log_in_dashboard_identity(obj: identity)

        get :index, protocol_id: protocol.id, format: :json
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User has view rights to Protocol" do
      render_views

      let!(:project_role) do
        obj = build_stubbed(:project_role,
          identity: identity,
          protocol: protocol)
        allow(protocol).to receive(:project_roles).and_return([obj])
        obj
      end

      before(:each) do
        authorize(identity, protocol, can_view: true, can_edit: :permission_to_edit)
        log_in_dashboard_identity(obj: identity)

        get :index, protocol_id: protocol.id, format: :json
      end

      it 'should set @protocol from params[:protocol_id]' do
        expect(assigns(:protocol)).to eq(protocol)
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it 'should set @permission_to_edit from ProtocolAuthorizer' do
        expect(assigns(:permission_to_edit)).to eq(:permission_to_edit)
      end

      it 'should set @protocol_roles to Protocol\'s ProjectRoles' do
        expect(assigns(:protocol_roles)).to eq([project_role])
      end

      it { is_expected.to render_template "dashboard/associated_users/index" }
      it { is_expected.to respond_with :ok }
    end

    def authorize(identity, protocol, opts = {})
      auth_mock = instance_double('ProtocolAuthorizer',
        'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
        'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
      allow(ProtocolAuthorizer).to receive(:new).
        and_return(auth_mock)
    end

    def stub_find_protocol(protocol_stub)
      allow(Protocol).to receive(:find).
          with(protocol_stub.id).
          and_return(protocol_stub)
    end
  end
end
