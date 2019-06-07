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

RSpec.describe NotifierLogic do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:logged_in_user)          { Identity.first }

  before :each do
    Delayed::Worker.delay_jobs = false
  end

  after :each do
    Delayed::Worker.delay_jobs = true
  end

  ### update_ssrs_and_send_emails ###
  context '#update_status_and_send_get_a_cost_estimate_email for an entire SR' do
    context 'create a new SR with all new services' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        @admin_email = 'hedwig@owlpost.com'
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: nil)
        ### SSR SETUP ###
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, submitted_at: nil, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, submitted_at: nil, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
        @sr.previous_submitted_at = @sr.submitted_at
        @sr.reload
      end

      it 'should notify authorized users (initial submission email)' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, nil, anything, false)
      end

      it 'should notify service providers (initial submission email)' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, nil, false, false)
      end

      it 'should notify admin (initial submission email)' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, nil, false)
      end

      it 'should send_user_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>false, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr, @ssr2],{:request_amendment=>false})
      end

      it 'should send_admin_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr, @ssr2],{:request_amendment=>false})
      end
    end

    context 'all SSRs have status of "get_a_cost_estimate"' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        @admin_email = 'hedwig@owlpost.com'
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: nil)
        ### SSR SETUP ###
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'get_a_cost_estimate', submitted_at: nil, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'get_a_cost_estimate', submitted_at: nil, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        @sr.previous_submitted_at = @sr.submitted_at
        @sr.reload
      end

      it 'NO EMAILS SENT' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).not_to have_received(:notify_user)
      end

      it 'NO EMAILS SENT' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'NO EMAILS SENT' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).not_to have_received(:notify_admin)
      end

      it 'should NOT send_user_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).not_to have_received(:send_user_notifications)
      end

      it 'should NOT send_service_provider_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).not_to have_received(:send_service_provider_notifications)
      end

      it 'should NOT send_admin_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).not_to have_received(:send_admin_notifications)
      end
    end

    context 'all SSRs have an updatable status' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        @admin_email = 'hedwig@owlpost.com'
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: nil)
        ### SSR SETUP ###
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'draft', submitted_at: nil, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
        @sr.previous_submitted_at = @sr.submitted_at
        @sr.reload
      end

      it 'should notify authorized users (initial submission email)' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, nil, anything, false)
      end

      it 'should notify service providers (initial submission email)' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, nil, false, false)
      end

      it 'should notify admin (initial submission email)' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, nil, false)
      end

      it 'should send_user_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>false, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr, @ssr2],{:request_amendment=>false})
      end

      it 'should send_admin_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr, @ssr2],{:request_amendment=>false})
      end
    end

    context 'one SSR has an updatable status and the other has an un-updatable status' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        @admin_email = 'hedwig@owlpost.com'
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: nil)
        ### SSR SETUP ###
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: nil, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
        @sr.previous_submitted_at = @sr.submitted_at
        @sr.reload
      end

      it 'should notify authorized users (initial submission email)' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, nil, anything, false)
      end

      it 'should notify service providers (initial submission email)' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, nil, false, false)
      end

      it 'should notify admin (initial submission email)' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_status_and_send_get_a_cost_estimate_email
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, nil, false)
      end

      it 'should send_user_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>false, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications with the updatable SSRs request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr2],{:request_amendment=>false})
      end

      it 'should send_admin_notifications with the updatable SSRs request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_status_and_send_get_a_cost_estimate_email
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr2],{:request_amendment=>false})
      end
    end
  end
end
