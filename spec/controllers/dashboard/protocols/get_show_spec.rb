require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #show' do
    context 'user not authorized to view Protocol' do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @logged_in_user)

        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(@logged_in_user, @protocol, can_view: false)

        get :show, id: @protocol.id
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(@protocol, @logged_in_user)
      end

      it { is_expected.to render_template "service_requests/_authorization_error" }
      it { is_expected.to respond_with :ok }
    end

    context 'user authorized to view Protocol, format: html' do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @logged_in_user)

        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        allow(@protocol).to receive(:service_requests).
          and_return("ServiceRequests")
        authorize(@logged_in_user, @protocol,
          can_view: true,
          can_edit: :permission_to_edit)

        @project_role = build_stubbed(:project_role)
        allow(@protocol.project_roles).to receive(:find_by).
          with(identity_id: @logged_in_user.id).
          and_return(@project_role)

        get :show, id: @protocol.id
      end

      it 'should set @protocol' do
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it 'should set @protocol_role to the ProjectRole of the logged in user pertinent to the Protocol' do
        expect(assigns(:protocol_role)).to eq(@project_role)
      end

      it "should set @permission_to_edit from ProtocolAuthorizer" do
        expect(assigns(:permission_to_edit)).to eq(:permission_to_edit)
      end

      it "should set @protocol_type to the type of Protocol" do
        expect(assigns(:protocol_type)).to eq("Project")
      end

      it "should set @service_requests to ServiceRequests of Protocol" do
        expect(assigns(:service_requests)).to eq("ServiceRequests")
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/protocols/show" }
    end
  end
end
