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
  describe 'patch update_protocol_type' do
    context 'user is an Authorized User' do
      context 'user not authorized to edit Protocol' do
        before(:each) do
          @logged_in_user = build_stubbed(:identity)
          @protocol = findable_stub(Protocol) do
            stub = build_stubbed(:protocol)
            allow(stub).to receive(:becomes).and_return(stub)
            stub
          end
          authorize(@logged_in_user, @protocol, can_edit: false)
          log_in_dashboard_identity(obj: @logged_in_user)
          patch :update_protocol_type, params: { id: @protocol.id }, xhr: true
        end

        it "should use ProtocolAuthorizer to authorize user" do
          expect(ProtocolAuthorizer).to have_received(:new).
            with(@protocol, @logged_in_user)
        end

        it { is_expected.to render_template "dashboard/shared/_authorization_error" }
        it { is_expected.to respond_with :ok }
      end

      context "user authorized to edit Protocol" do
        before(:each) do
          @logged_in_user = build_stubbed(:identity)
          log_in_dashboard_identity(obj: @logged_in_user)
          @study_type_question_group_version_3 = StudyTypeQuestionGroup.create(active: true, version: 3)
          study_type_question_group_version_2 = StudyTypeQuestionGroup.create(active: false, version: 2)
          @protocol = findable_stub(Protocol) do
            stub = build_stubbed(:protocol, type: "Study", study_type_question_group_id: study_type_question_group_version_2.id)
            allow(stub).to receive(:becomes).and_return(stub)
            stub
          end
          allow(@protocol).to receive(:update_attribute)
          allow(@protocol).to receive(:populate_for_edit)
          authorize(@logged_in_user, @protocol, can_edit: true)

          patch :update_protocol_type, params: { id: @protocol.id, type: "Project"}, xhr: true
        end

        it 'should set protocol_type' do
          expect(@protocol.type).to eq("Project")
        end

        it 'should set study_type_question_group to active' do
          expect(@protocol.study_type_question_group_id).to eq(@study_type_question_group_version_3.id)
        end

        it 'should populate Protocol for edit' do
          expect(@protocol.study_type_question_group_id).to eq(@study_type_question_group_version_3.id)
        end

        it { is_expected.to render_template "dashboard/protocols/update_protocol_type" }
        it { is_expected.to respond_with :ok }
      end
    end

    context 'user has Admin access' do
      context 'user not authorized to view Protocol' do
        before :each do
          @logged_in_user = create(:identity)
          @protocol       = create(:protocol_without_validations, type: 'Project')

          log_in_dashboard_identity(obj: @logged_in_user)

          patch :update_protocol_type, params: { id: @protocol.id }, xhr: true
        end

        it 'should set @admin to false' do
          expect(assigns(:admin)).to eq(false)
        end

        it { is_expected.to respond_with :ok }
        it { is_expected.to render_template "dashboard/shared/_authorization_error" }
      end

      context 'user authorized to view Protocol as Super User' do
        before :each do
          @logged_in_user = create(:identity)
          study_type_question_group_version_3 = StudyTypeQuestionGroup.create(active: true, version: 3)
          @protocol       = create(:protocol_without_validations, type: 'Project', study_type_question_group_id: study_type_question_group_version_3.id)
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request, status: 'draft', protocol_id: @protocol.id)
                            create(:super_user, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          patch :update_protocol_type, params: { id: @protocol.id }, xhr: true
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end

      context 'user authorized to view Protocol as Service Provider' do
        before :each do
          @logged_in_user = create(:identity)
          study_type_question_group_version_3 = StudyTypeQuestionGroup.create(active: true, version: 3)
          @protocol       = create(:protocol_without_validations, type: 'Project', study_type_question_group_id: study_type_question_group_version_3.id)
          organization    = create(:organization)
          service_request = create(:service_request_without_validations, protocol: @protocol)
                            create(:sub_service_request_without_validations, organization: organization, service_request: service_request, status: 'draft', protocol_id: @protocol.id)
                            create(:service_provider, identity: @logged_in_user, organization: organization)

          log_in_dashboard_identity(obj: @logged_in_user)

          patch :update_protocol_type, params: { id: @protocol.id }, xhr: true
        end

        it 'should set @admin to true' do
          expect(assigns(:admin)).to eq(true)
        end

        it { is_expected.to respond_with :ok }
      end
    end
  end
end
