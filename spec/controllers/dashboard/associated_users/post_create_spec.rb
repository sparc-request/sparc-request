require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'POST create' do
    def errors_stub(message)
      double(ActiveModel::Errors, full_messages: [message])
    end

    let!(:identity) do
      build_stubbed(:identity)
    end

    let!(:protocol) do
      obj = build_stubbed(:protocol)
      stub_find_protocol(obj)
      obj
    end

    context "User not authorized to edit Protocol" do
      render_views

      before(:each) do
        authorize(identity, protocol, can_edit: false)
        log_in_dashboard_identity(obj: identity)

        xhr :post, :create, protocol_id: protocol.id, format: :js
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol and params[:project_role] describes valid ProjectRole" do
      render_views

      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs = "@new_project_roles_attrs"
        new_project_role = instance_double(ProjectRole)
        associated_user_creator = instance_double(Dashboard::AssociatedUserCreator,
          successful?: true)
        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)

        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it "should use Dashboard::AssociatedUserCreator to create ProjectRole" do
        expect(Dashboard::AssociatedUserCreator).to have_received(:new).
          with(@new_project_roles_attrs)
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
      it { is_expected.to respond_with :ok }
    end

    context "User authorized to edit Protocol and params[:project_role] describes an invalid ProjectRole" do
      render_views

      before(:each) do
        authorize(identity, protocol, can_edit: true)
        log_in_dashboard_identity(obj: identity)

        @new_project_roles_attrs = "@new_project_roles_attrs"
        new_project_role = instance_double(ProjectRole, errors: errors_stub("my messages"))
        associated_user_creator = instance_double(Dashboard::AssociatedUserCreator,
          successful?: false,
          protocol_role: new_project_role)

        allow(Dashboard::AssociatedUserCreator).to receive(:new).
          and_return(associated_user_creator)

        xhr :post, :create, protocol_id: protocol.id, project_role: @new_project_roles_attrs, format: :js
      end

      it "should use Dashboard::AssociatedUserCreator to (attempt) to create ProjectRole" do
        expect(Dashboard::AssociatedUserCreator).to have_received(:new).
          with(@new_project_roles_attrs)
      end

      it "should set @errors" do
        expect(assigns(:errors).full_messages).to eq(["my messages"])
      end

      it { is_expected.to render_template "dashboard/associated_users/create" }
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
  end
end
