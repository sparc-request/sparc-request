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

RSpec.describe Notifier do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:service3)           { create(:service,
                                    organization_id: program.id,
                                    name: 'ABCD',
                                    one_time_fee: true) }
  let(:identity)          { Identity.first }
  let(:organization)      { Organization.first }
  let(:non_service_provider_org)  { create(:organization, name: 'BLAH', process_ssrs: 0, is_available: 1) }
  let(:service_provider)  { create(:service_provider,
                                    identity: identity,
                                    organization: organization,
                                    service: service3) }
  let!(:non_service_provider_ssr) { create(:sub_service_request, ssr_id: "0004", status: "submitted", service_request_id: service_request.id, organization_id: non_service_provider_org.id, org_tree_display: "SCTR1/BLAH")}

  before { add_visits }

  ############# WITHOUT NOTES #########################
  ############# ADDED AND DELETED LINE_ITEMS ###############
  context 'without notes' do
    context 'added and deleted line_items' do
      before :each do

        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        ssr = service_request.sub_service_requests.first
        ssr.update_attribute(:submitted_at, Time.now.yesterday)
        ssr.update_attribute(:status, 'submitted')
        @li_id = ssr.line_items.first.id
        ssr.line_items.first.destroy!
        ssr.save!
        service_request.reload

        created_li = create(:line_item_without_validations, sub_service_request_id: ssr.id, service_id: service3.id)
        @created_li_id = created_li.id
        ssr.save!
        service_request.reload

        @audit1 = AuditRecovery.where("auditable_id = '#{@li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        @audit2 = AuditRecovery.where("auditable_id = '#{@created_li_id}' AND auditable_type = 'LineItem' AND action = 'create'")

        @audit1.first.update_attribute(:created_at, Time.now - 5.hours)
        @audit1.first.update_attribute(:user_id, identity.id)
        @audit2.first.update_attribute(:created_at, Time.now - 5.hours)
        @audit2.first.update_attribute(:user_id, identity.id)

        @report = ssr.audit_report(identity, Time.now.yesterday - 4.hours, Time.now.tomorrow)
      end

      context 'service_provider' do
        let(:xls)                     { Array.new }
        let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        service_request.sub_service_requests.first.id,
                                                                        @report, false) }
        # Expected service provider message is defined under request_amendment_intro
        it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
          request_amendment_intro(mail)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_service_provider_request_amendment
          assert_email_request_amendment_for_added(mail.body)
          assert_email_request_amendment_for_deleted(mail.body)
        end

        it 'should not have a reminder note or submission reminder' do
          does_not_have_a_reminder_note(mail)
          does_not_have_a_submission_reminder(mail)
        end

        context 'when protocol has selected for epic' do

          before do
            service_request.protocol.update_attribute(:selected_for_epic, true)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(mail.body)
          end
        end
      end
    end

    context 'added line_items' do
      before do
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        ssr = service_request.sub_service_requests.first
        ssr.update_attribute(:submitted_at, Time.now.yesterday)
        ssr.update_attribute(:status, 'submitted')
        ssr.save!
        service_request.reload
        created_li = create(:line_item_without_validations, sub_service_request_id: ssr.id, service_id: service3.id)
        @created_li_id = created_li.id
        ssr.save!
        service_request.reload

        @audit2 = AuditRecovery.where("auditable_id = '#{@created_li_id}' AND auditable_type = 'LineItem' AND action = 'create'")

        @audit2.first.update_attribute(:created_at, Time.now - 5.hours)
        @audit2.first.update_attribute(:user_id, identity.id)

        @report = ssr.audit_report(identity, Time.now.yesterday - 4.hours, Time.now.tomorrow)

      end

      context 'service_provider' do
        let(:xls)                     { Array.new }
        let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        service_request.sub_service_requests.first.id,
                                                                        @report, false) }
        # Expected service provider message is defined under request_amendment_intro
        it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
          request_amendment_intro(mail)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_service_provider_request_amendment
          assert_email_request_amendment_for_added(mail.body)
        end

        it 'should not have a reminder note or submission reminder' do
          does_not_have_a_reminder_note(mail)
          does_not_have_a_submission_reminder(mail)
        end

        context 'when protocol has selected for epic' do

          before do
            service_request.protocol.update_attribute(:selected_for_epic, true)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(mail.body)
          end
        end
      end
    end

    context 'deleted line_items' do
      before do
        service_request.update_attribute(:submitted_at, Time.now.yesterday)
        ssr = service_request.sub_service_requests.first
        ssr.update_attribute(:submitted_at, Time.now.yesterday)
        ssr.update_attribute(:status, 'submitted')
        @li_id = ssr.line_items.first.id
        ssr.line_items.first.destroy!
        ssr.save!
        service_request.reload

        @audit1 = AuditRecovery.where("auditable_id = '#{@li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")

        @audit1.first.update_attribute(:created_at, Time.now - 5.hours)
        @audit1.first.update_attribute(:user_id, identity.id)
      
        @report = ssr.audit_report(identity, Time.now.yesterday - 4.hours, Time.now.tomorrow)
      end

      context 'service_provider' do
        let(:xls)                     { Array.new }
        let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        service_request.sub_service_requests.first.id,
                                                                        @report, false) }
        # Expected service provider message is defined under request_amendment_intro
        it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
          request_amendment_intro(mail)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_service_provider_request_amendment
          assert_email_request_amendment_for_deleted(mail.body)
        end

        it 'should not have a reminder note or submission reminder' do
          does_not_have_a_reminder_note(mail)
          does_not_have_a_submission_reminder(mail)
        end

        context 'when protocol has selected for epic' do

          before do
            service_request.protocol.update_attribute(:selected_for_epic, true)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(mail.body)
          end
        end
      end
    end
  end

  ############# WITH NOTES #########################
  context 'with notes' do

    before do
      create(:note_without_validations,
            identity_id:  identity.id, 
            notable_id: service_request.id)
      service_request.update_attribute(:submitted_at, Time.now.yesterday)
      ssr = service_request.sub_service_requests.first
      ssr.update_attribute(:submitted_at, Time.now.yesterday)
      ssr.update_attribute(:status, 'submitted')
      @li_id = ssr.line_items.first.id
      ssr.line_items.first.destroy!
      ssr.save!
      service_request.reload

      created_li = create(:line_item_without_validations, sub_service_request_id: ssr.id, service_id: service3.id)
      @created_li_id = created_li.id
      ssr.save!
      service_request.reload

      @audit1 = AuditRecovery.where("auditable_id = '#{@li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
      @audit2 = AuditRecovery.where("auditable_id = '#{@created_li_id}' AND auditable_type = 'LineItem' AND action = 'create'")

      @audit1.first.update_attribute(:created_at, Time.now - 5.hours)
      @audit1.first.update_attribute(:user_id, identity.id)
      @audit2.first.update_attribute(:created_at, Time.now - 5.hours)
      @audit2.first.update_attribute(:user_id, identity.id)

      @report = ssr.audit_report(identity, Time.now.yesterday - 4.hours, Time.now.tomorrow)
    end

    context 'service_provider' do
      let(:xls)                     { Array.new }
      let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        service_request.sub_service_requests.first.id,
                                                                        @report, false) }
      # Expected service provider message is defined under request_amendment_intro
      it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
        request_amendment_intro(mail)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_service_provider_request_amendment
        assert_email_request_amendment_for_added(mail.body)
        assert_email_request_amendment_for_deleted(mail.body)
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_have_a_reminder_note(mail)
        does_not_have_a_submission_reminder(mail)
      end
    end
  end
end