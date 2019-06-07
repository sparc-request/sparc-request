# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

  let(:identity) { jug2 }

  ############# WITHOUT NOTES #########################
  ############# ADDED AND DELETED LINE_ITEMS ###############
  context 'without notes' do
    context 'added and deleted line_items' do
      context 'service_provider' do
        context 'general' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @service_provider     = create(:service_provider, identity: identity, organization: @organization)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)


            @service_request.reload
            deleted_and_created_line_item_audit_trail(@service_request, @service, identity)

            @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
            @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
          end

          it 'should display correct subject' do
            expect(@mail).to have_subject("SPARCRequest Amendment Submitted (Protocol #{@protocol.id})")
          end

          # Expected service provider message is defined under request_amendment_intro
          it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
            request_amendment_intro(@mail)
          end

          it 'should render default tables' do
            assert_notification_email_tables_for_service_provider_request_amendment
            assert_email_request_amendment_for_added(@mail.body.parts.first.body)
            assert_email_request_amendment_for_deleted(@mail.body.parts.first.body)
          end

          it 'should not have a submission reminder' do
            does_not_have_a_submission_reminder(@mail)
          end
        end

        context 'when protocol has selected for epic' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @service_provider     = create(:service_provider, identity: identity, organization: @organization)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, selected_for_epic: true, funding_status: 'funded')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)


            @service_request.reload
            deleted_and_created_line_item_audit_trail(@service_request, @service, identity)

            @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
            @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
          end
        end
      end
    end

    context 'added line_items' do
      context 'service_provider' do
        context 'general' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @service_provider     = create(:service_provider, identity: identity, organization: @organization)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)


            @service_request.reload
            created_line_item_audit_trail(@service_request, @service, identity)

            @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
            @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
          end

          # Expected service provider message is defined under request_amendment_intro
          it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
            request_amendment_intro(@mail)
          end

          it 'should render default tables' do
            assert_notification_email_tables_for_service_provider_request_amendment
            assert_email_request_amendment_for_added(@mail.body.parts.first.body)
          end

          it 'should not have a submission reminder' do
            does_not_have_a_submission_reminder(@mail)
          end
        end

        context 'when protocol has selected for epic' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @service_provider     = create(:service_provider, identity: identity, organization: @organization)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, selected_for_epic: true, funding_status: 'funded')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)


            @service_request.reload
            created_line_item_audit_trail(@service_request, @service, identity)

            @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
            @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
          end
        end
      end

      context 'authorized users' do
        context 'general' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
            @project_role         = create(:project_role, identity: jug2, protocol: @protocol, project_rights: 'view')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
            @approval             = create(:approval, service_request: @service_request)


            @service_request.reload
            created_line_item_audit_trail(@service_request, @service, identity)

            @report               = setup_authorized_user_audit_report
            @mail                 = Notifier.notify_user(@project_role, @service_request, @approval, identity, @report)
          end

          # Expected service provider message is defined under request_amendment_intro
          it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
            request_amendment_intro(@mail)
          end

          it 'should render default tables' do
            assert_notification_email_tables_for_user
            assert_email_request_amendment_for_added(@mail.body.parts.first.body, true)
          end

          it 'should not have a submission reminder' do
            does_not_have_a_submission_reminder(@mail)
          end
        end

        context 'when protocol has selected for epic' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, selected_for_epic: true, funding_status: 'funded')
            @project_role         = create(:project_role, identity: jug2, protocol: @protocol, project_rights: 'view')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
            @approval             = create(:approval, service_request: @service_request)


            @service_request.reload
            created_line_item_audit_trail(@service_request, @service, identity)

            @report               = setup_authorized_user_audit_report
            @mail                 = Notifier.notify_user(@project_role, @service_request, @approval, identity, @report)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
          end
        end
      end

      context 'admin' do
        before :each do
          service_requester     = create(:identity)
          @organization         = create(:organization)
          @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
          create(:pricing_setup_without_validations, organization_id: @organization.id)
          @service_provider     = create(:service_provider, identity: identity, organization: @organization)
          @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
          @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
          @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
          @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)

          @service_request.reload
          created_line_item_audit_trail(@service_request, @service, identity)

          @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
          @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request, @report)
        end

        # Expected admin message is defined under get_a_cost_estimate_service_provider_admin_message
        it 'should display admin intro message, link, conclusion, and should not display acknowledgments' do
          request_amendment_intro(@mail)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_admin
          assert_email_request_amendment_for_added(@mail.body.parts.first.body)
        end
      end
    end

    context 'deleted line_items' do
      context 'service provider' do
        context 'general' do
          before do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @service_provider     = create(:service_provider, identity: identity, organization: @organization)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)


            @service_request.reload
            deleted_line_item_audit_trail(@service_request, @service, identity)

            @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
            @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
          end

          # Expected service provider message is defined under request_amendment_intro
          it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
            request_amendment_intro(@mail)
          end

          it 'should render default tables' do
            assert_notification_email_tables_for_service_provider_request_amendment
            assert_email_request_amendment_for_deleted(@mail.body.parts.first.body)
          end

          it 'should not have a submission reminder' do
            does_not_have_a_submission_reminder(@mail)
          end
        end

        context 'when protocol has selected for epic' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @service_provider     = create(:service_provider, identity: identity, organization: @organization)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, selected_for_epic: true, funding_status: 'funded')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)


            @service_request.reload
            deleted_line_item_audit_trail(@service_request, @service, identity)

            @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
            @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
          end
        end
      end

      context 'authorized users' do
        context 'general' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
            @project_role         = create(:project_role, identity: jug2, protocol: @protocol, project_rights: 'view')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
            @approval             = create(:approval, service_request: @service_request)


            @service_request.reload
            deleted_line_item_audit_trail(@service_request, @service, identity)

            @report               = setup_authorized_user_audit_report
            @mail                 = Notifier.notify_user(@project_role, @service_request, @approval, identity, @report)
          end

          # Expected service provider message is defined under request_amendment_intro
          it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
            request_amendment_intro(@mail)
          end

          it 'should render default tables' do
            assert_notification_email_tables_for_user
            assert_email_request_amendment_for_deleted(@mail.body.parts.first.body, true)
          end

          it 'should not have a submission reminder' do
            does_not_have_a_submission_reminder(@mail)
          end
        end

        context 'when protocol has selected for epic' do
          before :each do
            service_requester     = create(:identity)
            @organization         = create(:organization)
            @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
            create(:pricing_setup_without_validations, organization_id: @organization.id)
            @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, selected_for_epic: true, funding_status: 'funded')
            @project_role         = create(:project_role, identity: jug2, protocol: @protocol, project_rights: 'view')
            @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
            @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
            @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
            @approval             = create(:approval, service_request: @service_request)


            @service_request.reload
            deleted_line_item_audit_trail(@service_request, @service, identity)

            @report               = setup_authorized_user_audit_report
            @mail                 = Notifier.notify_user(@project_role, @service_request, @approval, identity, @report)
          end

          it 'should show epic column' do
            assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
          end
        end
      end

      context 'admin' do
        before do
          service_requester     = create(:identity)
          @organization         = create(:organization)
          @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
          create(:pricing_setup_without_validations, organization_id: @organization.id)
          @service_provider     = create(:service_provider, identity: identity, organization: @organization)
          @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
          @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
          @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
          @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)

          @service_request.reload
          deleted_line_item_audit_trail(@service_request, @service, identity)

          @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
          @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request, @report)
        end

        # Expected admin message is defined under get_a_cost_estimate_service_provider_admin_message
        it 'should display admin intro message, link, conclusion, and should not display acknowledgments' do
          request_amendment_intro(@mail)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_admin
          assert_email_request_amendment_for_deleted(@mail.body.parts.first.body)
        end
      end
    end
  end

  ############# WITH NOTES #########################
  context 'with notes' do
    context 'service provider' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service              = create(:service, organization: @organization, one_time_fee: true, pricing_map_count: 1)
        create(:pricing_setup_without_validations, organization_id: @organization.id)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:project_without_validations, funding_source: 'college', primary_pi: jpl6, funding_status: 'funded')
        @service_request      = create(:service_request_without_validations, protocol: @protocol, submitted_at: Time.now.yesterday, status: 'submitted')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @line_item            = create(:line_item_without_validations, sub_service_request: @sub_service_request, service_request: @service_request, service: @service)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)

        @service_request.reload
        deleted_and_created_line_item_audit_trail(@service_request, @service, identity)

        @report               = @sub_service_request.audit_report(identity, Time.now.yesterday - 4.hours, Time.now)
        @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, @report, false, true)
      end

      # Expected service provider message is defined under request_amendment_intro
      it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
        request_amendment_intro(@mail)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_service_provider_request_amendment
        assert_email_request_amendment_for_added(@mail.body.parts.first.body)
        assert_email_request_amendment_for_deleted(@mail.body.parts.first.body)
      end

      it 'should not have a submission reminder' do
        does_not_have_a_submission_reminder(@mail)
      end
    end
  end
end
