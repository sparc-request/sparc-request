# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

  context 'service_provider' do
    context 'general' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)
        @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request)

        @service_request.reload
      end

      it 'should display correct subject' do
        expect(@mail).to have_subject("SPARCRequest Get Cost Estimate (Protocol #{@protocol.id})")
      end

      # Expected service provider message is defined under get_a_cost_estimate_service_provider_admin_message
      it 'should display service_provider intro message, link, conclusion, and should not display acknowledgments' do
        get_a_cost_estimate_intro_for_service_providers
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_service_provider
      end

      it 'should not have a submission reminder' do
        does_not_have_a_submission_reminder(@mail)
      end
    end

    context 'when protocol has selected for epic' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6, selected_for_epic: true)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
        @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request)
        
        @service_request.reload
      end

      it 'should show epic column' do
        assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
      end
    end

    context 'when protocol is not selected for epic' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6, selected_for_epic: false)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
        @mail                 = Notifier.notify_service_provider(@service_provider, @service_request, identity, @sub_service_request)
        
        @service_request.reload
      end

      it 'should not show epic column' do
        assert_email_user_information_when_not_selected_for_epic(@mail.body.parts.first.body)
      end
    end
  end

  context 'authorized users' do
    context 'general' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6)
        @project_role         = create(:project_role, identity: identity, project_rights: 'view')
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @approval             = create(:approval, service_request: @service_request)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)
        @mail                 = Notifier.notify_user(@project_role, @service_request, nil, @approval, identity)
        
        @service_request.reload
      end

      # Expected user message is defined under get_a_cost_estimate_general_users
      it 'should have user intro message, conclusion, and acknowledgments' do
        get_a_cost_estimate_intro_for_general_users
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_user
      end

      it 'should not have a submission reminder' do
        does_not_have_a_submission_reminder(@mail.body.parts.first.body)
      end
    end

    context 'when protocol has selected for epic' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6, selected_for_epic: true)
        @project_role         = create(:project_role, identity: identity, project_rights: 'view')
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @approval             = create(:approval, service_request: @service_request)
        @mail                 = Notifier.notify_user(@project_role, @service_request, nil, @approval, identity)
        
        @service_request.reload
      end

      it 'should show epic column' do
        assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
      end
    end

    context 'when protocol is not selected for epic' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6, selected_for_epic: false)
        @project_role         = create(:project_role, identity: identity, project_rights: 'view')
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @approval             = create(:approval, service_request: @service_request)
        @mail                 = Notifier.notify_user(@project_role, @service_request, nil, @approval, identity)
        
        @service_request.reload
      end

      it 'should not show epic column' do
        assert_email_user_information_when_not_selected_for_epic(@mail.body.parts.first.body)
      end
    end
  end

  context 'admin' do
    context 'general' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
        @note                 = create(:note_without_validations, identity: identity, notable: @protocol)
        @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request)
        
        @service_request.reload
      end

      # Expected admin message is defined under get_a_cost_estimate_service_provider_admin_message
      it 'should display admin intro message, link, conclusion, and should not display acknowledgments' do
        get_a_cost_estimate_intro_for_admin
      end

      it 'should render default tables' do
        assert_notification_email_tables_for_admin
      end

      it 'should not have a submission reminder' do
        does_not_have_a_submission_reminder(@mail.body.parts.first.body)
      end
    end

    context 'when protocol has selected for epic' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6, selected_for_epic: true)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
        @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request)
        
        @service_request.reload
      end

      it 'should show epic column' do
        assert_email_user_information_when_selected_for_epic(@mail.body.parts.first.body)
      end
    end

    context 'when protocol is not selected for epic' do
      before :each do
        service_requester     = create(:identity)
        @organization         = create(:organization)
        @service_provider     = create(:service_provider, identity: identity, organization: @organization)
        @protocol             = create(:study_without_validations, funding_source: 'college', funding_status: 'funded', primary_pi: jpl6, selected_for_epic: false)
        @service_request      = create(:service_request_without_validations, protocol: @protocol, status: 'get_a_cost_estimate')
        @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, protocol: @protocol, organization: @organization, service_requester: service_requester)
        @submission_email     = create(:submission_email, email: 'success@musc.edu', organization: @organization)
        @mail                 = Notifier.notify_admin(@submission_email, identity, @sub_service_request)
        
        @service_request.reload
      end

      it 'should not show epic column' do
        assert_email_user_information_when_not_selected_for_epic(@mail.body.parts.first.body)
      end
    end
  end
end
