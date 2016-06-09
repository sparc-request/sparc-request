require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'PUT update' do
    let!(:identity) { build_stubbed(:identity) }

    before(:each) { log_in_dashboard_identity(obj: identity) }

    context 'user not authorized to edit Protocol associated with ProjectRole' do
      before(:each) do
        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(identity, @protocol, can_edit: false)

        project_role = findable_stub(ProjectRole) do
          build_stubbed(:project_role, protocol: @protocol)
        end

        xhr :put, :update,  id: project_role.id, 
                            protocol_id: @protocol.id
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(@protocol, identity)
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:project_role] describes a valid update to ProjectRole with id params[:id]" do
      before(:each) do
        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(identity, @protocol, can_edit: true)

        @project_role = findable_stub(ProjectRole) do
          build_stubbed(:project_role, protocol: @protocol)
        end

        project_role_updater = instance_double(Dashboard::AssociatedUserUpdater,
          successful?: true, # valid in this context
          protocol_role: @project_role)

        allow(Dashboard::AssociatedUserUpdater).to receive(:new).
          and_return(project_role_updater)

        xhr :put, :update, id: @project_role.id, protocol_id: @protocol.id, project_role: {identity_id: '1'}
      end

      it 'should update @protocol_role using params[:project_role] using ProtocolUpdater' do
        expect(Dashboard::AssociatedUserUpdater).to have_received(:new).
          with(id: @project_role.id.to_s, project_role: {identity_id: '1'})
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

    context "params[:project_role] describes an invalid update to ProjectRole with id params[:id]" do
      before(:each) do
        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(identity, @protocol, can_edit: true)

        @project_role = findable_stub(ProjectRole) do
          build_stubbed(:project_role, protocol: @protocol)
        end
        allow(@project_role).to receive(:errors).and_return("my errors")

        @project_role_updater = instance_double(Dashboard::AssociatedUserUpdater,
          successful?: false, # valid in this context
          protocol_role: @project_role)

        allow(Dashboard::AssociatedUserUpdater).to receive(:new).and_return(@project_role_updater)

        xhr :put, :update, id: @project_role.id, protocol_id: @protocol.id, project_role: {identity_id: '1'}
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
  end
end
