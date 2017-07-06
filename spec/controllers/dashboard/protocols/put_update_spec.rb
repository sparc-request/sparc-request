# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe Dashboard::ProtocolsController do
  describe 'PUT #update' do
    context 'user is an Authorized User' do
      context "user is not authorized to edit Protocol" do
        before(:each) do
          @logged_in_user = build_stubbed(:identity)
          log_in_dashboard_identity(obj: @logged_in_user)
          @protocol = create(:protocol_federally_funded, primary_pi: @logged_in_user)
          authorize(@logged_in_user, @protocol, can_edit: false)

          get :update, params: { id: @protocol.id }, xhr: true
        end

        it { is_expected.to respond_with :ok }
        it { is_expected.to render_template "dashboard/shared/_authorization_error" }
      end

      context "user authorized to edit Protocol" do
        context 'params[:protocol] results in valid Protocol' do
          before(:each) do
            @logged_in_user = build_stubbed(:identity)
            log_in_dashboard_identity(obj: @logged_in_user)

            @protocol = create(:protocol_federally_funded, primary_pi: @logged_in_user)
            authorize(@logged_in_user, @protocol, can_edit: true)

            # let us have an active StudyTypeQuestionGroup
            allow(StudyTypeQuestionGroup).to receive(:active_id).
              and_return("active group id")

            get :update, params: { id: @protocol.id, protocol: { title: "New Title" } }, xhr: true
          end

          it "should update Protocol <- params[:id] as specified in params[:protocol] and update its StudyTypeQuestionGroup to the active one" do
            @protocol.reload
            expect(@protocol.title).to eq("New Title")
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

            @protocol = create(:protocol_without_validations,
                primary_pi: @logged_in_user,
                funding_status: "funded",
                funding_source: "skrill",
                title: "")
            authorize(@logged_in_user, @protocol, can_edit: true)

            # let us have an active StudyTypeQuestionGroup
            allow(StudyTypeQuestionGroup).to receive(:active_id).
              and_return("active group id")

            get :update, params: { id: @protocol.id, protocol: { some_attribute: "some value" } }, xhr: true
          end

          it 'should set @errors to Protocol\'s errors attribute' do
            expect(assigns(:errors).full_messages).to eq(["Title can't be blank"])
          end
        end
      end
    end

    context 'user does not have Admin access nor a valid project role' do
      before :each do
        @logged_in_user = create(:identity)
        @protocol       = create(:protocol_without_validations)

        log_in_dashboard_identity(obj: @logged_in_user)

        get :update, params: { id: @protocol.id }, xhr: true
      end

      it 'should set @admin to false' do
        expect(assigns(:admin)).to eq(false)
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template "dashboard/shared/_authorization_error" }
    end

    context 'user has Admin access but not a valid project role' do
      context 'user authorized to edit Protocol as Super User' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations,
                                    primary_pi: @logged_in_user,
                                    funding_status: "funded",
                                    funding_source: "foundation")
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request, status: 'draft', protocol_id: @protocol.id)
                            create(:super_user, identity: @logged_in_user, organization: organization)
          @study_type_question_group_version_3 = StudyTypeQuestionGroup.create(active: true, version: 3)
          log_in_dashboard_identity(obj: @logged_in_user)
        end

        it 'should set @admin to true' do

          get :update, params: { id: @protocol.id, protocol: { title: "some value", selected_for_epic: "true", study_type_question_group_id: @study_type_question_group_version_3.id } }, xhr: true
          expect(assigns(:admin)).to eq(true)
        end

        it 'should allow blank Research Master ID with human subjects' do
          stub_const("RESEARCH_MASTER_ENABLED", true)
          @protocol.research_master_id = 1
          @protocol.save(validate: false)

          get :update, params: { id: @protocol.id, protocol: { research_master_id: nil } }, xhr: true
          @protocol.reload

          expect(@protocol.research_master_id).to be_nil
        end

        it 'should not save with blank RMID with other invalid params' do
          stub_const("RESEARCH_MASTER_ENABLED", true)
          @protocol.research_master_id = 1
          @protocol.save(validate: false)

          get :update, params: { id: @protocol.id, protocol: { title: "", research_master_id: nil } }, xhr: true
          @protocol.reload

          expect(@protocol.research_master_id).to eq(1)
        end

        it 'should respond ok' do
          get :update, params: { id: @protocol.id, protocol: { title: "some value" } }, xhr: true
          expect(controller).to respond_with(:ok)
        end
      end

      context 'user authorized to edit Protocol as Service Provider' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations,
                                    primary_pi: @logged_in_user,
                                    funding_status: "funded",
                                    funding_source: "foundation")
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request, status: 'draft', protocol_id: @protocol.id)
                            create(:service_provider, identity: @logged_in_user, organization: organization)
          @study_type_question_group_version_3 = StudyTypeQuestionGroup.create(active: true, version: 3)
          log_in_dashboard_identity(obj: @logged_in_user)
        end

        it 'should set @admin to true' do
          get :update, params: { id: @protocol.id, protocol: { title: "some value", selected_for_epic: "true", study_type_question_group_id: @study_type_question_group_version_3.id } }, xhr: true
          expect(assigns(:admin)).to eq(true)
        end

        it 'should allow blank Research Master ID with human subjects' do
          stub_const("RESEARCH_MASTER_ENABLED", true)
          @protocol.research_master_id = 1
          @protocol.save(validate: false)

          get :update, params: { id: @protocol.id, protocol: { research_master_id: nil } }, xhr: true
          @protocol.reload

          expect(@protocol.research_master_id).to be_nil
        end

        it 'should not save with blank RMID with other invalid params' do
          stub_const("RESEARCH_MASTER_ENABLED", true)
          @protocol.research_master_id = 1
          @protocol.save(validate: false)

          get :update, params: { id: @protocol.id, protocol: { title: "", research_master_id: nil } }, xhr: true
          @protocol.reload

          expect(@protocol.research_master_id).to eq(1)
        end

        it 'should respond ok' do
          get :update, params: { id: @protocol.id, protocol: { title: "some value" } }, xhr: true
          expect(controller).to respond_with(:ok)
        end
      end
    end
  end
end
