require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #show' do
    context 'user is an Authorized User' do
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

        it "should set @permission_to_edit from ProtocolAuthorizer" do
          expect(assigns(:permission_to_edit)).to eq(:permission_to_edit)
        end

        it "should set @protocol_type to the type of Protocol" do
          expect(assigns(:protocol_type)).to eq("Project")
        end

        it { is_expected.to respond_with :ok }
        it { is_expected.to render_template "dashboard/protocols/show" }
      end
    end

    context 'user has Admin access' do
      context 'user not authorized to view Protocol' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations, type: 'Project')

          log_in_dashboard_identity(obj: @logged_in_user)

          get :show, id: @protocol.id
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
          @protocol       = create(:protocol_without_validations, type: 'Project')
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:super_user, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :show, id: @protocol.id
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end

      context 'user authorized to view Protocol as Service Provider' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations, type: 'Project')
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:service_provider, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :show, id: @protocol.id
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end
    end
  end
end
