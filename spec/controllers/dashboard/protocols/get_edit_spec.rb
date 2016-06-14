require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'GET #edit' do
    context 'user is an Authorized User' do
      context 'user not authorized to edit Protocol' do
        before(:each) do
          @logged_in_user = build_stubbed(:identity)

          @protocol = findable_stub(Protocol) do
            build_stubbed(:protocol, type: "Project")
          end
          authorize(@logged_in_user, @protocol, can_edit: false)

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

      context "user authorized to edit Protocol" do
        context "protocol has inactive study_type_question_group_id" do

          build_study_type_question_groups
          before(:each) do
            @logged_in_user = build_stubbed(:identity)
            @protocol       = findable_stub(Protocol) do
              build_stubbed(:protocol,
                type: "Study",
                study_type_question_group_id: inactive_study_type_question_group.id
              )
            end

            allow(@protocol).to receive(:valid?).and_return(true)
            allow(@protocol).to receive(:populate_for_edit)
            allow(@protocol).to receive(:update_attribute).and_return(true)

            authorize(@logged_in_user, @protocol, can_edit: true)

            log_in_dashboard_identity(obj: @logged_in_user)

            get :edit, id: @protocol.id
          end

          it "should assign @protocol_type to type of Protocol" do
            expect(assigns(:protocol_type)).to eq("Study")
          end

          it "should populate Protocol for edit" do
            expect(@protocol).to have_received(:populate_for_edit)
          end

          it "should update StudyTypeQuestionGroup id" do
            expect(@protocol).to have_received(:update_attribute).
              with(:study_type_question_group_id, active_study_type_question_group.id)
          end
          it { is_expected.to respond_with :ok }
          it { is_expected.to render_template "dashboard/protocols/edit" }
        end
        context "protocol has active study_type_question_group_id" do

          build_study_type_question_groups
          before(:each) do
            @logged_in_user = build_stubbed(:identity)
            @protocol       = findable_stub(Protocol) do
              build_stubbed(:protocol,
                type: "Study",
                study_type_question_group_id: active_study_type_question_group.id
              )
            end

            allow(@protocol).to receive(:valid?).and_return(true)
            allow(@protocol).to receive(:populate_for_edit)
            allow(@protocol).to receive(:update_attribute).and_return(true)

            authorize(@logged_in_user, @protocol, can_edit: true)

            log_in_dashboard_identity(obj: @logged_in_user)

            get :edit, id: @protocol.id
          end

          it "should assign @protocol_type to type of Protocol" do
            expect(assigns(:protocol_type)).to eq("Study")
          end

          it "should populate Protocol for edit" do
            expect(@protocol).to have_received(:populate_for_edit)
          end

          it "should update StudyTypeQuestionGroup id" do
            expect(@protocol).to have_received(:update_attribute).
              with(:study_type_question_group_id, active_study_type_question_group.id)
          end
          it { is_expected.to respond_with :ok }
          it { is_expected.to render_template "dashboard/protocols/edit" }
        end
      end
    end

    context 'user does not have Admin access nor a valid project role' do
      before :each do
        @logged_in_user = create(:identity)
        @protocol       = create(:protocol_without_validations, type: 'Project')

        log_in_dashboard_identity(obj: @logged_in_user)

        get :edit, id: @protocol.id
      end

      it 'should set @admin to false' do
        expect(assigns(:admin)).to eq(false)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "service_requests/_authorization_error" }
    end

    context 'user has Admin access but not a valid project role' do
      context 'user authorized to edit Protocol as Super User' do
        build_study_type_question_groups
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations, type: 'Study', study_type_question_group_id: inactive_study_type_question_group.id)
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:super_user, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :edit, id: @protocol.id
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end

      context 'user authorized to edit Protocol as Service Provider' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations, type: 'Project')
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:service_provider, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          get :edit, id: @protocol.id
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end
    end
  end
end
