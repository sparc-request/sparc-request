require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET new' do
    let!(:identity) do
      findable_stub(Identity) { build_stubbed(:identity) }
    end

    let(:primary_pi) { build_stubbed(:identity) }

    let!(:protocol) do
      obj = findable_stub(Protocol) { build_stubbed(:protocol) }
      allow(obj).to receive(:primary_principal_investigator).
        and_return(primary_pi)
      obj
    end

    context "User not authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it { is_expected.to render_template "dashboard/shared/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol" do
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
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        # stub ProjectRole creation, a little complicated
        @project_roles_association = instance_double(ActiveRecord::Relation)
        @new_project_role = build_stubbed(:project_role)
        allow(@new_project_role).to receive(:unique_to_protocol?).
          and_return(true)
        allow(protocol).to receive(:project_roles).
          and_return(@project_roles_association)
        allow(@project_roles_association).to receive(:new).
          and_return(@new_project_role)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it "should build a ProjectRole for Protocol using params[:identity_id]" do
        expect(@project_roles_association).to have_received(:new).
          with(identity_id: identity.id)
      end

      it 'should set @identity to the Identity from params[:identity_id]' do
        expect(assigns(:identity)).to eq(identity)
      end

      it 'should set @current_pi to the Primary PI of @protocol' do
        expect(assigns(:current_pi)).to eq(primary_pi)
      end

      it 'should set @project_role to a new ProjectRole associated with @protocol' do
        expect(assigns(:project_role)).to eq(@new_project_role)
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:identity_id] present and not unique to Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        # stub ProjectRole creation, a little complicated
        @project_roles_association = instance_double(ActiveRecord::Relation)
        @new_project_role = build_stubbed(:project_role)
        allow(@new_project_role).to receive(:unique_to_protocol?).and_return(false)
        allow(@new_project_role).to receive(:errors).and_return("errors")
        allow(protocol).to receive(:project_roles).
          and_return(@project_roles_association)
        allow(@project_roles_association).to receive(:new).
          and_return(@new_project_role)

        xhr :get, :new, protocol_id: protocol.id, identity_id: identity.id, format: :js
      end

      it 'should set @errors' do
        expect(assigns(:errors)).to eq("errors")
      end

      it { is_expected.to render_template "dashboard/associated_users/new" }
      it { is_expected.to respond_with :ok }
    end
  end
end
