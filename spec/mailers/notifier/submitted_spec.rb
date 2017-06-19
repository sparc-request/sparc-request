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

  let(:identity) { jug2 }

  ############# WITHOUT NOTES #########################
  context 'without notes' do
    context 'service_provider' do
      context 'general' do
        before :each do
          @organization         = create(:organization)
          @service_provider     = create(:service_provider, identity: identity, organization: @organization)
          @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6)
          @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
          @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, [], false)
          
          @service_request.reload
        end

        it 'should display correct subject' do
          expect(@mail).to have_subject("#{@protocol.id} - SPARCRequest service request")
        end
        # Expected service provider message is defined under submitted_service_provider_and_admin_message
        it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
          submitted_intro_for_service_providers_and_admin(@mail)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_service_provider
        end

        it 'should have a notes reminder message but not a submission reminder' do
          does_not_have_a_reminder_note(@mail)
          does_not_have_a_submission_reminder(@mail)
        end

        it 'should not have audited information table' do
          expect(@mail).not_to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
        end
      end

      context 'when protocol has selected for epic' do
        before :each do
          @organization         = create(:organization)
          @service_provider     = create(:service_provider, identity: identity, organization: @organization)
          @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6, selected_for_epic: true)
          @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
          @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, [], false)
          
          @service_request.reload
        end

        it 'should show epic column' do
          assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
        end
      end
    end

    context 'authorized users' do
      context 'general' do
        before :each do
          @organization         = create(:organization)
          @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6)
          @project_role         = create(:project_role, identity: identity, project_rights: 'view')
          @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
          @approval             = create(:approval, service_request: @service_request)
          @mail                 = Notifier.notify_user(@project_role, @service_request, false, @approval, identity)
          
          @service_request.reload
        end

        # Expected user message is defined under submitted_general_users_message
        it 'should have user intro message, conclusion, and acknowledgments' do
          submitted_intro_for_general_users
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_user
        end

        it 'should have a notes reminder message but not a submission reminder' do
          does_not_have_a_reminder_note(@mail.body.parts.first.body)
          does_have_a_submission_reminder(@mail.body.parts.first.body)
        end
      end

      context 'when protocol has selected for epic' do
        before :each do
          @organization         = create(:organization)
          @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6, selected_for_epic: true)
          @project_role         = create(:project_role, identity: identity, project_rights: 'view')
          @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
          @approval             = create(:approval, service_request: @service_request)
          @mail                 = Notifier.notify_user(@project_role, @service_request, false, @approval, identity)
          
          @service_request.reload
        end

        it 'should show epic column' do
          assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
        end
      end
    end

    context 'admin' do
      context 'general' do
        before :each do
          @organization         = create(:organization)
          @service_provider     = create(:service_provider, identity: identity, organization: @organization)
          @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6)
          @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
          @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
          @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request)
          
          @service_request.reload
        end

        # Expected admin message is defined under submitted_service_provider_and_admin_message
        it 'should display admin intro message, conclusion, link, and should not display acknowledgments' do
          submitted_intro_for_service_providers_and_admin(@mail.body.parts.first.body)
        end

        it 'should render default tables' do
          assert_notification_email_tables_for_admin
        end

        it 'should have a notes reminder message but not a submission reminder' do
          does_not_have_a_reminder_note(@mail.body.parts.first.body)
          does_not_have_a_submission_reminder(@mail.body.parts.first.body)
        end
      end

      context 'when protocol has selected for epic' do
        before :each do
          @organization         = create(:organization)
          @service_provider     = create(:service_provider, identity: identity, organization: @organization)
          @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6, selected_for_epic: true)
          @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
          @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
          @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
          @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request)
          
          @service_request.reload
        end

        it 'should show epic column' do
          assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
        end
      end
    end
  end

  ############# WITH NOTES #########################
  context 'with notes' do
    context 'service_provider' do
      before :each do
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)
        @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request, [], false)
        
        @service_request.reload
      end

      # Expected service provider message is defined under submitted_service_provider_and_admin_message
      it 'should display admin intro message, conclusion, link, and should not display acknowledgments' do
        submitted_intro_for_service_providers_and_admin(@mail)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_service_provider
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_have_a_reminder_note(@mail)
        does_not_have_a_submission_reminder(@mail)
      end

      it 'should not have audited information table' do
        expect(@mail).not_to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
      end
    end

    context 'authorized users' do
      before :each do
        @organization         = create(:organization)
        @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6)
        @project_role         = create(:project_role, identity: identity, project_rights: 'view')
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
        @approval             = create(:approval, service_request: @service_request)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)
        @mail                 = Notifier.notify_user(@project_role, @service_request, false, @approval, identity)
      
        @service_request.reload
      end

      # Expected user message is defined under submitted_general_users_message
      it 'should have user intro message, conclusion, and acknowledgments' do
        submitted_intro_for_general_users
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_user
      end

      it 'should NOT have a notes reminder message but have a submission reminder' do
        does_not_have_a_reminder_note(@mail.body.parts.first.body)
        does_have_a_submission_reminder(@mail.body.parts.first.body)
      end
    end

    context 'admin' do
      before :each do
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'cash flow', primary_pi: jpl6)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'submitted')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization)
        @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)
        @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request)
        
        @service_request.reload
      end

      # Expected service provider message is defined under submitted_service_provider_and_admin_message
      it 'should display admin intro message, conclusion, link, and should not display acknowledgments' do
        submitted_intro_for_service_providers_and_admin(@mail.body.parts.first.body)
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_admin
      end

      it 'should have a notes reminder message but not a submission reminder' do
        does_have_a_reminder_note(@mail)
        does_not_have_a_submission_reminder(@mail)
      end
    end
  end
end
