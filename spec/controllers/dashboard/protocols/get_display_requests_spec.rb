require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #display_requests' do
    context 'user is an Authorized User' do
      context 'user not authorized to view Protocol' do
        before :each do
          @logged_in_user = build_stubbed(:identity)

          @protocol = findable_stub(Protocol) do
            build_stubbed(:protocol, type: "Project")
          end
          authorize(@logged_in_user, @protocol, can_view: false)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :display_requests, id: @protocol.id, format: :js
        end

        it "should use ProtocolAuthorizer to authorize user" do
          expect(ProtocolAuthorizer).to have_received(:new).
            with(@protocol, @logged_in_user)
        end

        it { is_expected.to respond_with :ok }
        it { is_expected.to render_template "service_requests/_authorization_error" }
      end

      context "user authorized to view Protocol" do
        before :each do
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

        it { is_expected.to respond_with :ok }
      end
    end

    context 'user has Admin access' do
      context 'user not authorized to view Protocol' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :display_requests, id: @protocol.id, format: :js
        end

        it 'should set @admin to false' do
          expect(assigns(:admin)).to eq(false)
        end

        it { is_expected.to respond_with :ok }
        it { is_expected.to render_template "service_requests/_authorization_error" }
      end

      context 'user authorized to view Protocol as Super User' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations)
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:super_user, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :display_requests, id: @protocol.id, format: :js
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end

      context 'user authorized to view Protocol as Service Provider' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations)
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:service_provider, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :display_requests, id: @protocol.id, format: :js
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end
    end
  end
end
