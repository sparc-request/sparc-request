require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'PUT #update' do
    context 'user is an Authorized User' do
      context "user is not authorized to edit Protocol" do
        before(:each) do
          @logged_in_user = build_stubbed(:identity)
          log_in_dashboard_identity(obj: @logged_in_user)
          @protocol = findable_stub(Protocol) do
            build_stubbed(:protocol, type: "Project")
          end
          authorize(@logged_in_user, @protocol, can_edit: false)

          xhr :get, :update, id: @protocol.id
        end

        it { is_expected.to respond_with :ok }
        it { is_expected.to render_template "service_requests/_authorization_error" }
      end

      context "user authorized to edit Protocol" do
        context 'params[:protocol] results in valid Protocol' do
          before(:each) do
            @logged_in_user = build_stubbed(:identity)
            log_in_dashboard_identity(obj: @logged_in_user)

            @protocol = findable_stub(Protocol) do
              build_stubbed(:protocol, type: "Project")
            end
            authorize(@logged_in_user, @protocol, can_edit: true)

            # let us have an active StudyTypeQuestionGroup
            allow(StudyTypeQuestionGroup).to receive(:active_id).
              and_return("active group id")

            allow(@protocol).to receive(:update_attributes).
              and_return(true)

            xhr :get, :update, id: @protocol.id, protocol: { some_attribute: "some value" }
          end

          it "should update Protocol <- params[:id] as specified in params[:protocol] and update its StudyTypeQuestionGroup to the active one" do
            expect(@protocol).to have_received(:update_attributes).
              with(some_attribute: "some value", study_type_question_group_id: "active group id")
          end

          it "should not set @errors" do
            expect(assigns(:errors)).to be_nil
          end

          it { is_expected.to respond_with :ok }
          it { is_expected.to render_template "dashboard/protocols/update" }
        end

        context 'params[:protocol] results in invalid Protocol' do
          before(:each) do
            @logged_in_user = build_stubbed(:identity)
            log_in_dashboard_identity(obj: @logged_in_user)

            @protocol = findable_stub(Protocol) do
              build_stubbed(:protocol, type: "Project")
            end
            allow(@protocol).to receive(:errors).and_return("oh god")
            authorize(@logged_in_user, @protocol, can_edit: true)

            # let us have an active StudyTypeQuestionGroup
            allow(StudyTypeQuestionGroup).to receive(:active_id).
              and_return("active group id")

            allow(@protocol).to receive(:update_attributes).
              and_return(false)

            xhr :get, :update, id: @protocol.id, protocol: { some_attribute: "some value" }
          end

          it 'should set @errors to Protocol\'s errors attribute' do
            expect(assigns(:errors)).to eq('oh god')
          end
        end
      end
    end

    context 'user does not have Admin access nor a valid project role' do
      before :each do
        @logged_in_user = create(:identity)
        @protocol       = create(:protocol_without_validations, type: 'Project')

        log_in_dashboard_identity(obj: @logged_in_user)

        xhr :get, :update, id: @protocol.id
      end

      it 'should set @admin to false' do
        expect(assigns(:admin)).to eq(false)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "service_requests/_authorization_error" }
    end

    context 'user has Admin access but not a valid project role' do
      context 'user authorized to edit Protocol as Super User' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations, type: 'Project')
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request)
                            create(:super_user, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          xhr :get, :update, id: @protocol.id, protocol: { title: "some value" }
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

          xhr :get, :update, id: @protocol.id, protocol: { title: "some value" }
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end
    end
  end
end
