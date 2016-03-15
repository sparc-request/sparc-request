require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET new' do
    let!(:identity) do
      obj = instance_double(Identity, id: 1)
      stub_find_identity(obj)
      obj
    end

    let!(:protocol) do
      # stub #new for creating new ProjectRoles for Protocol
      project_roles_association = double('project_roles_association')
      allow(project_roles_association).to receive(:new).
          with(identity_id: identity.id).
          and_return(project_role)

      obj = instance_double(Protocol, id: 2, project_roles: project_roles_association, primary_principal_investigator: :primary_pi)

      stub_find_protocol(obj)
      obj
    end

    let!(:project_role) { instance_double(ProjectRole) }

    before(:each) do
      log_in_dashboard_identity(obj: identity)
      authorize(identity, protocol, can_edit: true)
    end

    context 'params[:identity_id] present' do
      it 'should set @identity to the Identity from params[:identity_id]' do
        allow(project_role).to receive('unique_to_protocol?').and_return(true)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js

        expect(assigns(:identity)).to eq(identity)
      end

      it 'should set @current_pi to the Primary PI of @protocol' do
        allow(project_role).to receive('unique_to_protocol?').and_return(true)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js

        expect(assigns(:current_pi)).to eq(:primary_pi)
      end

      it 'should set @project_role to a new ProjectRole associated with @protocol' do
        allow(project_role).to receive('unique_to_protocol?').and_return(true)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js

        expect(assigns(:project_role)).to eq(project_role)
      end

      it 'should set @errors if user already added to Protocol' do
        allow(project_role).to receive('unique_to_protocol?').and_return(false)
        expect(project_role).to receive(:errors).and_return(:errors)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js

        expect(assigns(:errors)).to eq(:errors)
      end
    end

    it 'should set @header_text to "Add Associated User"' do
      xhr :get, :new, protocol_id: protocol.id, format: :js

      expect(assigns(:header_text)).to eq('Add Authorized User')
    end

    def authorize(identity, protocol, opts = {})
      auth_mock = instance_double('ProtocolAuthorizer',
                                  'can_view?' => opts[:can_view].nil? ? false : opts[:can_view],
                                  'can_edit?' => opts[:can_edit].nil? ? false : opts[:can_edit])
      expect(ProtocolAuthorizer).to receive(:new).
          with(protocol, identity).
          and_return(auth_mock)
    end

    def stub_find_protocol(obj)
      allow(Protocol).to receive(:find).
          with(obj.id).
          and_return(obj)
    end

    def stub_find_project_role(obj)
      allow(ProjectRole).to receive(:find).
          with(obj.id.to_s).
          and_return(obj)
    end

    def stub_find_identity(obj)
      allow(Identity).to receive(:find).
        with(obj.id).
        and_return(obj)
    end
  end
end
