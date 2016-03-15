require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET edit' do
    let!(:identity) do
      instance_double(Identity, id: 1)
    end

    let!(:protocol) do
      instance_double(Protocol, id: 2, primary_principal_investigator: :primary_pi)
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
      authorize(identity, protocol, can_edit: true)
      log_in_dashboard_identity(obj: identity)
    end

    it 'should set @protocol_role from params[:id]' do
      xhr :get, :edit, id: project_role.id, format: :js

      expect(assigns(:protocol_role)).to eq(project_role)
    end

    it 'should set @protocol from @project_role.protocol' do
      xhr :get, :edit, id: project_role.id, format: :js

      expect(assigns(:protocol)).to eq(protocol)
    end

    it 'should set @identity to the Identity associated with @project_role' do
      xhr :get, :edit, id: project_role.id, format: :js

      expect(assigns(:identity)).to eq(identity)
    end

    it 'should set @current_pi to the Primary PI of @protocol' do
      xhr :get, :edit, id: project_role.id, format: :js

      expect(assigns(:current_pi)).to eq(:primary_pi)
    end

    it 'should set @header_text to "Edit Authorized User"' do
      xhr :get, :edit, id: project_role.id, format: :js

      expect(assigns(:header_text)).to eq('Edit Authorized User')
    end

    def stub_find_protocol(protocol_stub)
      allow(Protocol).to receive(:find).
          with(protocol_stub.id).
          and_return(protocol_stub)
    end

    def authorize(identity, protocol, opts = {})
      auth_mock = instance_double('ProtocolAuthorizer',
                                  'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
                                  'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
      expect(ProtocolAuthorizer).to receive(:new).
          with(protocol, identity).
          and_return(auth_mock)
    end

    def stub_find_project_role(obj)
      allow(ProjectRole).to receive(:find).
          with(obj.id.to_s).
          and_return(obj)
    end
  end
end
