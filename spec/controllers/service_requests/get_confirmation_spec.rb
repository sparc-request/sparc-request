# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#confirmation' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #validate_step' do
      expect(before_filters.include?(:validate_step)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should update previous_submitted_at' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-06-01')
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id] = logged_in_user.id

      get :confirmation, params: { srid: sr.id }, xhr: true

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    context 'editing a service request' do
      it 'should set submitted at to now' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: nil)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id] = logged_in_user.id
        time                  = Time.parse('2016-06-01 12:34:56')

        Timecop.freeze(time) do
          get :confirmation, params: { srid: sr.id }, xhr: true
          expect(sr.reload.submitted_at).to eq(time)
        end
      end

      it 'should update status to submitted and approvals to false' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                   create(:service_provider, identity: logged_in_user, organization: org)

        session[:identity_id] = logged_in_user.id

        get :confirmation, params: { srid: sr.id }, xhr: true

        expect(sr.reload.status).to eq('submitted')
        expect(ssr.reload.nursing_nutrition_approved).to eq(false)
        expect(ssr.reload.lab_approved).to eq(false)
        expect(ssr.reload.imaging_approved).to eq(false)
        expect(ssr.reload.committee_approved).to eq(false)
      end

      context 'using EPIC and queue_epic' do
        stub_config("use_epic", true)
        stub_config("queue_epic", true)

        it 'should create an item in the queue' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true, send_to_epic: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study', selected_for_epic: true)
          sr       = create(:service_request_without_validations, protocol: protocol)
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

          session[:identity_id] = logged_in_user.id

          setup_valid_study_answers(protocol)

          get :confirmation, params: { srid: sr.id }, xhr: true

          expect(EpicQueue.count).to eq(1)
          expect(EpicQueue.first.protocol_id).to eq(protocol.id)
        end
      end

      context 'using EPIC but not queue_epic' do
        stub_config("use_epic", true)

        it 'should notify' do
          org      = create(:organization)
          service  = create(:service, organization: org, one_time_fee: true, send_to_epic: true)
          protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study', selected_for_epic: true)
          sr       = create(:service_request_without_validations, protocol: protocol, submitted_at: (Time.now + 1.day))
          ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol_id: protocol.id)
          li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
                     create(:service_provider, identity: logged_in_user, organization: org)
          org.submission_emails.create(email: 'hedwig@owlpost.com')

          session[:identity_id] = logged_in_user.id

          setup_valid_study_answers(protocol)

          # We have an admin, user, and service_provider so we send 3 emails
          get :confirmation, params: {
            srid: sr.id
          }, xhr: true
            
          expect(Delayed::Backend::ActiveRecord::Job.count).to eq(3)
        end
      end
    end

    it 'should render template' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id] = logged_in_user.id

      get :confirmation, params: { srid: sr.id }, xhr: true

      expect(controller).to render_template(:confirmation)
    end

    it 'should respond ok' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      session[:identity_id] = logged_in_user.id

      get :confirmation, params: { srid: sr.id }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end

def add_li_creating_a_new_ssr_then_delete_li_destroying_ssr(sr, ssr, ssr2)
  audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
  audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

  audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
  audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.utc)

  added_li = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{ssr2.id}%' AND auditable_type = 'LineItem' AND action IN ('create')")
  added_li.first.update_attribute(:created_at, Time.now.utc)
  added_li.first.update_attribute(:user_id, logged_in_user.id)

  ssr2.line_items.first.destroy!
  sr.sub_service_requests.last.destroy!
  sr.reload
  updated_ssr = AuditRecovery.where("auditable_id = #{ssr2.id} AND action = 'update'")
  updated_ssr.first.update_attribute(:created_at, Time.now.utc - 5.minutes)
  # destroyed_ssr = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{ssr2.id}%' AND action = 'destroy'")
  sr.previous_submitted_at = sr.submitted_at
end

def setup_valid_study_answers(protocol)
  question_group = StudyTypeQuestionGroup.create(active: true)
  question_1     = StudyTypeQuestion.create(friendly_id: 'certificate_of_conf', study_type_question_group_id: question_group.id)
  question_2     = StudyTypeQuestion.create(friendly_id: 'higher_level_of_privacy', study_type_question_group_id: question_group.id)
  question_3     = StudyTypeQuestion.create(friendly_id: 'access_study_info', study_type_question_group_id: question_group.id)
  question_4     = StudyTypeQuestion.create(friendly_id: 'epic_inbasket', study_type_question_group_id: question_group.id)
  question_5     = StudyTypeQuestion.create(friendly_id: 'research_active', study_type_question_group_id: question_group.id)
  question_6     = StudyTypeQuestion.create(friendly_id: 'restrict_sending', study_type_question_group_id: question_group.id)

  answer         = StudyTypeAnswer.create(protocol_id: protocol.id, study_type_question_id: question_1.id, answer: true)
end
