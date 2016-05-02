require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET new' do
    let!(:identity) do
      findable_stub(Identity) { build_stubbed(:identity) }
    end

    let(:primary_pi) do
      build_stubbed(:identity)
    end

    let!(:protocol) do
      obj = findable_stub(Protocol) { build_stubbed(:protocol) }
      allow(obj).to receive(:primary_principal_investigator).
        and_return(primary_pi)
      obj
    end

    context "User not authorized to edit Protocol" do
      render_views

      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol" do
      render_views

      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :new, protocol_id: protocol.id, format: :js
      end

      it 'should set @header_text to "Add Associated User"' do
        expect(assigns(:header_text)).to eq('Add Authorized User')
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end

    context 'params[:identity_id] present and unique to Protocol' do
      let!(:new_project_role) do
        # stub ProjectRole creation
        project_roles_association = double('project_roles_association')
        project_role = instance_double(ProjectRole, unique_to_protocol?: true)
        allow(protocol).to receive(:project_roles).and_return(project_roles_association)
        allow(project_roles_association).to receive(:new).
          with(identity_id: identity.id).
          and_return(project_role)
        project_role
      end

      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it 'should set @identity to the Identity from params[:identity_id]' do
        expect(assigns(:identity)).to eq(identity)
      end

      it 'should set @current_pi to the Primary PI of @protocol' do
        expect(assigns(:current_pi)).to eq(primary_pi)
      end

      it 'should set @project_role to a new ProjectRole associated with @protocol' do
        expect(assigns(:project_role)).to eq(new_project_role)
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:identity_id] present and not unique to Protocol" do
      let!(:new_project_role) do
        # stub ProjectRole creation
        project_roles_association = double('project_roles_association')
        project_role = instance_double(ProjectRole,
          unique_to_protocol?: false,
          errors: "errors")
        allow(protocol).to receive(:project_roles).and_return(project_roles_association)
        allow(project_roles_association).to receive(:new).
          with(identity_id: identity.id).
          and_return(project_role)
        project_role
      end

      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it 'should set @errors' do
        expect(assigns(:errors)).to eq("errors")
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
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
  end
end
