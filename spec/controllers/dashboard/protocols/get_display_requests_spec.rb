require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #display_requests' do
    context 'user not authorized to view Protocol' do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        @protocol = findable_stub(Protocol) do
          build_stubbed(:protocol, type: "Project")
        end
        authorize(@logged_in_user, @protocol, can_view: false)

        log_in_dashboard_identity(obj: @logged_in_user)
        get :edit, id: @protocol.id
      end

      it "should use ProtocolAuthorizer to authorize user" do
        expect(ProtocolAuthorizer).to have_received(:new).
          with(@protocol, @logged_in_user)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "service_requests/_authorization_error" }
    end

    context "user authorized to view Protocol" do
      before(:each) do
        @user = build_stubbed(:identity)
        log_in_dashboard_identity(obj: @user)

        @protocol = findable_stub(Protocol) { build_stubbed(:protocol) }
        authorize(@user, @protocol, can_view: true)

        @project_role = create(:project_role,
          identity_id: @user.id,
          protocol_id: @protocol.id)
        allow(@protocol.project_roles).to receive(:find_by).
          with(identity_id: @user.id).
          and_return(@project_role)

        xhr :get, :display_requests, id: @protocol.id, format: :js
      end

      it "should set @protocol to Protocol <- params[:id]" do
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it "should set @protocol_role to user's ProjectRole under @protocol" do
        expect(assigns(:protocol_role)).to eq(@project_role)
      end

      it "should set @permission_to_edit based on ProjectRole's permissions" do
        expect(assigns(:permission_to_edit)).to eq(@project_role.can_edit?)
      end

      it { is_expected.to respond_with :ok }
    end
  end
end
