require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET edit' do
    let!(:identity) do
      build_stubbed(:identity)
    end

    let!(:primary_pi) do
      build_stubbed(:identity)
    end

    let!(:protocol) do
      obj = build_stubbed(:protocol)
      allow(obj).to receive(:primary_principal_investigator)
        .and_return(primary_pi)
      obj
    end

    let!(:project_role) do
      obj = findable_stub(ProjectRole) do
        build_stubbed(:project_role,
          identity: identity,
          protocol: protocol)
      end
      allow(protocol).to receive(:project_roles).and_return([obj])
      obj
    end

    context "User not authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :edit, id: project_role.id, format: :js
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(protocol, identity)
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol" do
      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        xhr :get, :edit, id: project_role.id, format: :js
      end

      it 'should set @protocol_role from params[:id]' do
        expect(assigns(:protocol_role)).to eq(project_role)
      end

      it 'should set @protocol to Protocol of @project_role' do
        expect(assigns(:protocol)).to eq(protocol)
      end

      it 'should set @identity to the Identity associated with @project_role' do
        expect(assigns(:identity)).to eq(identity)
      end

      it 'should set @current_pi to the Primary PI of @protocol' do
        expect(assigns(:current_pi)).to eq(primary_pi)
      end

      it 'should set @header_text to "Edit Authorized User"' do
        expect(assigns(:header_text)).to eq('Edit Authorized User')
      end

      it { is_expected.to render_template "dashboard/associated_users/edit" }
      it { is_expected.to respond_with :ok }
    end
  end
end
