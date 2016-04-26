require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'PUT update' do
    let!(:identity_stub) { instance_double('Identity', id: 1) }

    before(:each) do
      log_in_dashboard_identity(obj: identity_stub)
    end

    context 'user not authorized to edit Protocol associated with ProjectRole' do
      render_views

      before(:each) do
        protocol = instance_double('Protocol',
          id: 1,
          type: "protocol type")
        stub_find_protocol(protocol)
        authorize(identity_stub, protocol, can_edit: false)

        project_role = instance_double('ProjectRole',
          id: 1,
          protocol: protocol)
        stub_find_project_role(project_role)

        xhr :put, :update, id: project_role.id
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:project_role] describes a valid update to ProtjectRole with id params[:id]" do
      before(:each) do
        protocol = instance_double('Protocol',
          id: 1,
          type: "protocol type")
        stub_find_protocol(protocol)
        authorize(identity_stub, protocol, can_edit: true)

        @project_role = instance_double('ProjectRole',
          id: 1,
          protocol: protocol)
        stub_find_project_role(@project_role)

        project_role_updater = instance_double(Dashboard::AssociatedUserUpdater,
          successful?: true, # valid in this context
          protocol_role: @project_role)

        allow(Dashboard::AssociatedUserUpdater).to receive(:new).
          and_return(project_role_updater)

        xhr :put, :update, id: @project_role.id, project_role: "project role attrs"
      end

      it 'should update @protocol_role using params[:project_role] using ProtocolUpdater' do
        expect(Dashboard::AssociatedUserUpdater).to have_received(:new).
          with(id: @project_role.id.to_s, project_role: "project role attrs")
      end

      it 'should not set @errors' do
        expect(assigns(:errors)).to be_nil
      end

      it 'should set flash[:success]' do
        expect(flash[:success]).not_to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:project_role] describes an invalid update to ProtjectRole with id params[:id]" do
      before(:each) do
        protocol = instance_double('Protocol',
          id: 1,
          type: "protocol type")
        stub_find_protocol(protocol)
        authorize(identity_stub, protocol, can_edit: true)

        @project_role = instance_double('ProjectRole',
          id: 1,
          errors: "my errors",
          protocol: protocol)
        stub_find_project_role(@project_role)

        @project_role_updater = instance_double(Dashboard::AssociatedUserUpdater,
          successful?: false, # valid in this context
          protocol_role: @project_role)

        allow(Dashboard::AssociatedUserUpdater).to receive(:new).and_return(@project_role_updater)

        xhr :put, :update, id: @project_role.id, project_role: "project role attrs"
      end

      it 'should set @errors' do
        expect(assigns(:errors)).to eq("my errors")
      end

      it 'should not set flash[:success]' do
        expect(flash[:success]).to be_nil
      end

      it { is_expected.to render_template "dashboard/associated_users/update" }
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

    def stub_find_project_role(pr)
      allow(ProjectRole).to receive(:find).with(pr.id.to_s).and_return(pr)
    end

    def stub_find_protocol(protocol_stub)
      allow(Protocol).to receive(:find).with(protocol_stub.id.to_s).and_return(protocol_stub)
    end
  end
end
