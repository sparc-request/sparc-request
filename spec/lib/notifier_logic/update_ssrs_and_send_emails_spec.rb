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
  context '#update_ssrs_and_send_emails for an entire SR' do
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
        new_sr(@sr, @ssr, @ssr2)
        @sr.reload
      end

      it 'should notify authorized users (initial submission email)' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, nil, anything, false)
      end

      it 'should notify service providers (initial submission email)' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, nil, false, false)
      end

      it 'should notify admin (initial submission email)' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, nil, false)
      end

      it 'should send_user_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>false, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr, @ssr2],{:request_amendment=>false})
      end

      it 'should send_admin_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr, @ssr2],{:request_amendment=>false})
      end
    end

    context 'deleted an entire SSR and resubmit SR' do
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
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
        ### DELETE LINE ITEM WHICH IN TURNS DELETES SSR ###
        # mimics the service_requests_controller remove_service method
        @destroyed_li_id = li.id
        li.destroy
        ssr.update_attribute(:status, 'draft')
        ssr.destroy
        @sr.reload
        ### DELETES AN ENTIRE SSR AND SETS UP ASSOCIATED AUDIT ###
        delete_entire_ssr(@sr, ssr, ssr2)
        ### Deleted LIs since previously submitted ###
        @deleted_li = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{ssr.id}%' AND auditable_type = 'LineItem' AND action IN ('destroy')")
        @deleted_ssr = AuditRecovery.where("audited_changes LIKE '%service_request_id: #{ssr.id}%' AND auditable_type = 'SubServiceRequest' AND action = 'destroy'")
        @deleted_li.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        @deleted_li.first.update_attribute(:user_id, logged_in_user.id)
        @sr.reload
      end

      it 'should notify authorized users' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        audit = { :line_items => @deleted_li }
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, audit, anything, false)
      end

      it 'should NOT notify service providers' do
        allow(Notifier).to receive(:notify_service_provider)
        audit = { :line_items => @deleted_li }
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails

        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'should NOT notify admin' do
        @sr.previous_submitted_at = @sr.submitted_at
        allow(Notifier).to receive(:notify_admin)

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).not_to have_received(:notify_admin)
      end

      it 'should send_user_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>true, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should NOT send_service_provider_notifications' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).not_to have_received(:send_service_provider_notifications)
      end

      it 'should NOT send_admin_notifications' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).not_to have_received(:send_admin_notifications)
      end
    end

    context 'added a service to a new SSR, then delete that same service which destroys that SSR and resubmit SR' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: nil, submitted_at: nil, service_requester: service_requester)
        @ssr2.update_attribute(:status, 'draft')
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        @sr.reload
        add_li_creating_a_new_ssr_then_delete_li_destroying_ssr(@sr, ssr, @ssr2)
      end

      it 'NO EMAILS' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).not_to have_received(:notify_user)
      end

      it 'NO EMAILS' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'NO EMAILS' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).not_to have_received(:notify_admin)
      end

      it 'should send_user_notifications request_amendment=>true but is later filtered out for the authorized user report' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>true, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).not_to have_received(:send_service_provider_notifications)
      end

      it 'should send_admin_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).not_to have_received(:send_admin_notifications)
      end
    end

    context 'added a service to a new SSR and resubmit SR' do
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
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
        @sr.reload
        add_li_adding_a_new_ssr(@sr, ssr, @ssr2)

        @added_li = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{@ssr2.id}%' AND auditable_type = 'LineItem' AND action IN ('create')")
        @added_li.first.update_attribute(:created_at, Time.now.utc - 5.minutes)
        @added_li.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should notify authorized users (request_amendment_email)' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        audit = { :line_items => @added_li }
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, audit, anything, false)
      end

      it 'should notify service providers (initial submission email)' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, nil, false, false)
      end

      it 'should notify admin (initial submission email)' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, nil, false)
      end

      it 'should send_user_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>true, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr2],{:request_amendment=>false})
      end

      it 'should send_admin_notifications request_amendment=>false' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr2],{:request_amendment=>false})
      end
    end

    context 'previously submitted ssr that has added services' do
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
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        li_2        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)

        @ssr2.update_attribute(:status, 'draft')
        @sr.reload
        add_li_to_exisiting_ssr(@sr, ssr, @ssr2, li_2)
        @added_li = AuditRecovery.where("auditable_id = '#{li_2.id}' AND auditable_type = 'LineItem' AND action IN ('create')")
        @added_li.first.update_attribute(:created_at, Time.now.yesterday.utc + 5.hours)
        @added_li.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should notify authorized users' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        audit = { :line_items => @added_li }
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, audit, anything, false)
      end

      it 'should notify service providers' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        audit = { :line_items => @added_li, :sub_service_request_id => @ssr2.id }
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, audit, false, true)
      end

      it 'should notify admin' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        audit = { :line_items => @added_li, :sub_service_request_id => @ssr2.id }
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, audit, false)
      end

      it 'should send_user_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>true, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr2],{:request_amendment=>true})
      end

      it 'should send_admin_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr2],{:request_amendment=>true})
      end
    end

    context 'previously submitted ssr that has deleted services' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org)
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        @admin_email = 'hedwig@owlpost.com'
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
        li_2        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)

        destroyed_li_id = li_2.id
        @ssr2.update_attributes(status: 'submitted', submitted_at: Time.now.yesterday.utc + 1.hours)
        li_2.destroy
        @ssr2.update_attribute(:status, 'draft')
        @sr.reload
        delete_li_from_exisiting_ssr(@sr, ssr, @ssr2, destroyed_li_id)

        @deleted_li = AuditRecovery.where("auditable_id = '#{destroyed_li_id}' AND auditable_type = 'LineItem' AND action IN ('destroy')")
        @deleted_li.first.update_attribute(:created_at, Time.now.utc - 1.hours)
        @deleted_li.first.update_attribute(:user_id, logged_in_user.id)
      end

      it 'should notify authorized users' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        audit = { :line_items => @deleted_li }
        project_role = @sr.protocol.project_roles.first
        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_user).with(project_role, @sr, false, logged_in_user, audit, anything, false)
      end

      it 'should notify service providers' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        audit = { :line_items => @deleted_li, :sub_service_request_id => @ssr2.id }

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr2, audit, false, true)
      end

      it 'should notify admin' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end
        audit = { :line_items => @deleted_li, :sub_service_request_id => @ssr2.id }

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr2, audit, false)
      end

      it 'should send_user_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>true, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr2],{:request_amendment=>true})
      end

      it 'should send_admin_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr2],{:request_amendment=>true})
      end
    end

    context 'previously submitted SSR (existing SSR) that has added and deleted services' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2         = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org.submission_emails.create(email: 'hedwig@owlpost.com')
        service     = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        ### LINE ITEM SETUP ###
        li          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        li_2        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)

        destroyed_li_id = li_2.id

        li_2.destroy
        @ssr2.update_attribute(:status, 'draft')
        @sr.reload
        delete_li_and_add_li_from_exisiting_ssr(@sr, ssr, @ssr2, li_1, destroyed_li_id)
      end

      it 'should notify authorized users' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_user)
      end

      it 'should notify service providers' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_service_provider)
      end

      it 'should notify admin' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).update_ssrs_and_send_emails
        expect(Notifier).to have_received(:notify_admin)
      end

      it 'should send_user_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_user_notifications).with({:request_amendment=>true, :admin_delete_ssr=>false, :deleted_ssr=>nil})
      end

      it 'should send_service_provider_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_service_provider_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_service_provider_notifications).with([@ssr2],{:request_amendment=>true})
      end

      it 'should send_admin_notifications request_amendment=>true' do
        @notifier_logic =  NotifierLogic.new(@sr, logged_in_user)
        allow(@notifier_logic).to receive(:send_admin_notifications)
        @notifier_logic.update_ssrs_and_send_emails
        expect(@notifier_logic).to have_received(:send_admin_notifications).with([@ssr2],{:request_amendment=>true})
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
    sr.previous_submitted_at = sr.submitted_at
    sr.reload
  end

  def delete_entire_ssr(sr, ssr, ssr2)
    ### Setting up audits for emails ###
    ### Changing time for the created_at, so this SSR does not show up in audit ###
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    ### Deleted SSRs since previously submitted ###
    deleted_ssrs_since_previous_submission = AuditRecovery.where("audited_changes LIKE '%service_request_id: #{sr.id}%' AND auditable_type = 'SubServiceRequest' AND action = 'destroy' AND created_at BETWEEN '#{Time.now.yesterday.utc}' AND '#{Time.now.utc}'")
    deleted_ssrs_since_previous_submission.first.update_attribute(:created_at, Time.now.utc - 5.hours)
    deleted_ssrs_since_previous_submission.first.update_attribute(:user_id, logged_in_user.id)
    ### Change last status to an 'unupdatable' status ###
    destroyed_ssr = AuditRecovery.where("auditable_id = #{ssr.id} AND action = 'update'").order(created_at: :desc).first
    destroyed_ssr.update_attributes(audited_changes: {'status'=>["submitted", "blah"]} )


    sr.previous_submitted_at = sr.submitted_at
  end


  def add_li_adding_a_new_ssr(sr, ssr, ssr2)
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.utc - 5.minutes)

    ### Needed for SSR#audit_line_items ###
    AuditRecovery.create(auditable_id: ssr2.id, auditable_type: 'SubServiceRequest', action:  'update', audited_changes: {"submitted_at"=>[nil, Time.now]}, user_id: logged_in_user.id, created_at: Time.now.utc - 5.minutes)

    sr.previous_submitted_at = sr.submitted_at
  end

  def add_li_to_exisiting_ssr(sr, ssr, ssr2, li_2)
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    # submitted_at_ssr2 = AuditRecovery.where("audited_changes LIKE '%submitted_at%' AND auditable_id = #{ssr2.id} AND auditable_type = 'SubServiceRequest' AND action IN ('update')").order(created_at: :desc).first

    AuditRecovery.create(auditable_id: ssr2.id, auditable_type: 'SubServiceRequest', action:  'update', audited_changes: {"submitted_at"=>[Time.now.yesterday, Time.now.yesterday + 1.hours]}, user_id: logged_in_user.id, created_at: Time.now.utc - 5.minutes)

    sr.previous_submitted_at = sr.submitted_at
  end

  def delete_li_from_exisiting_ssr(sr, ssr, ssr2, destroyed_li_id)
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    submitted_at_ssr2 = AuditRecovery.where("audited_changes LIKE '%submitted_at%' AND auditable_id = #{ssr2.id} AND auditable_type = 'SubServiceRequest' AND action IN ('update')").order(created_at: :desc).first
    submitted_at_ssr2.update_attribute(:user_id, logged_in_user.id)
    sr.previous_submitted_at = sr.submitted_at
  end

  def delete_li_and_add_li_from_exisiting_ssr(sr, ssr, ssr2, li_1, destroyed_li_id)
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    deleted_li = AuditRecovery.where("auditable_id = '#{destroyed_li_id}' AND auditable_type = 'LineItem' AND action IN ('destroy')")
    deleted_li.first.update_attribute(:created_at, Time.now.utc - 1.hours)
    deleted_li.first.update_attribute(:user_id, logged_in_user.id)

    added_li = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action IN ('create')")
    added_li.first.update_attribute(:created_at, Time.now.yesterday.utc - 1.hours)
    added_li.first.update_attribute(:user_id, logged_in_user.id)

    AuditRecovery.create(auditable_id: ssr2.id, auditable_type: 'SubServiceRequest', action:  'update', audited_changes: {"submitted_at"=>[Time.now.yesterday, Time.now.yesterday + 1.hours]}, user_id: logged_in_user.id, created_at: Time.now.utc - 5.minutes)

    sr.previous_submitted_at = sr.submitted_at
  end

  def new_sr(sr, ssr, ssr2)
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.utc - 1.minutes)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.utc - 1.minutes)

    added_li = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{ssr.id}%' AND auditable_type = 'LineItem' AND action IN ('create')")
    added_li.first.update_attribute(:created_at, Time.now.utc - 1.minutes)
    added_li.first.update_attribute(:user_id, logged_in_user.id)

    added_li = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{ssr2.id}%' AND auditable_type = 'LineItem' AND action IN ('create')")
    added_li.first.update_attribute(:created_at, Time.now.utc - 1.minutes)
    added_li.first.update_attribute(:user_id, logged_in_user.id)

    sr.previous_submitted_at = sr.submitted_at
  end
end
