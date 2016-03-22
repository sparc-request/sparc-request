require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET show' do
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
      authorize(identity, protocol, can_view: true)
      log_in_dashboard_identity(obj: identity)
    end

    context 'params[:id] set to id of Identity associated with Protocol' do
      it 'should set @user' do
        get :show, id: identity.id, protocol_id: protocol.id, format: :js

        expect(assigns(:user)).to eq(identity)
      end
    end

    context 'params[:id] set to id of Identity not associated with Protocol' do
      it 'should set @user to nil' do
        get :show, id: 0, protocol_id: protocol.id, format: :js

        expect(assigns(:user)).to be_nil
      end
    end

    it 'should set @protocol' do
      get :show, id: identity.id, protocol_id: protocol.id, format: :js

      expect(assigns(:protocol)).to eq(protocol)
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
