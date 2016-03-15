require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET index' do
    let!(:identity) do
      instance_double(Identity, id: 1)
    end

    let!(:protocol) do
      obj = instance_double(Protocol,
                            id: 2)
      stub_find_protocol(obj)
      obj
    end

    let!(:project_role) do
      obj = instance_double(ProjectRole,
                            id: 3,
                            identity: identity,
                            protocol: protocol)
      stub_find_project_role(obj)
      allow(protocol).to receive(:project_roles).and_return([obj])
      obj
    end

    before(:each) do
      authorize(identity, protocol, can_view: true, can_edit: :permission_to_edit)
      log_in_dashboard_identity(obj: identity)
    end

    it 'should set @protocol from params[:protocol_id] when present' do
      get :index, protocol_id: protocol.id, format: :json

      expect(assigns(:protocol)).to eq(protocol)
    end

    it 'should set @protocol from params[:project_role][protocol_id] when present' do
      get :index, project_role: { protocol_id: protocol.id }, format: :json

      expect(assigns(:protocol)).to eq(protocol)
    end

    it 'should set @permission_to_edit' do
      get :index, protocol_id: protocol.id, format: :json

      expect(assigns(:permission_to_edit)).to eq(:permission_to_edit)
    end

    it 'should set @protocol_roles to Protocol\'s ProjectRoles' do
      get :index, protocol_id: protocol.id, format: :json

      expect(assigns(:protocol_roles)).to eq([project_role])
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
  end
end
