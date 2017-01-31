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

RSpec.describe NotifierLogic do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:logged_in_user)          { Identity.first }

  context '#send_request_amendment_email_evaluation' do
    context 'deleted an entire SSR and resubmit SR' do
      before :each do
         @org         = create(:organization_with_process_ssrs)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil)
        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
                      
        @ssr.destroy
        @sr.reload
        audit = AuditRecovery.where("auditable_id = '#{li.id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        audit.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)

        audit_of_ssr = AuditRecovery.where("auditable_id = '#{@ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'destroy'")
        audit_of_ssr.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        audit_of_ssr.first.update_attribute(:user_id, logged_in_user.id)
        @sr.previous_submitted_at = @sr.submitted_at
      end

      it 'should notify authorized users' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail') 
          expect(mailer).to receive(:deliver_now)
          mailer
        end

        NotifierLogic.new(@sr, nil, logged_in_user).send_request_amendment_email_evaluation
        expect(Notifier).to have_received(:notify_user) 
      end

      it 'should NOT notify service providers' do
        allow(Notifier).to receive(:notify_service_provider) 
        NotifierLogic.new(@sr, nil, logged_in_user).send_request_amendment_email_evaluation
        expect(Notifier).not_to have_received(:notify_service_provider)
      end

      it 'should NOT notify admin' do
        @sr.previous_submitted_at = @sr.submitted_at
        allow(Notifier).to receive(:notify_admin) 
        
        NotifierLogic.new(@sr, nil, logged_in_user).send_request_amendment_email_evaluation 
        expect(Notifier).not_to have_received(:notify_admin)
      end

      it 'should send_user_notifications' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.send_request_amendment_email_evaluation 
      end

      it 'should not send_request_amendment' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).not_to receive(:send_request_amendment)
        @notifier_logic.send_request_amendment_email_evaluation 
      end
    end

    context 'added a service to a new SSR and resubmit SR' do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        service     = create(:service, organization: @org, one_time_fee: true)
        service2    = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)

        @ssr2        = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'draft', submitted_at: nil)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service2)
                      create(:service_provider, identity: logged_in_user, organization: @org)

        audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
        audit.first.update_attribute(:created_at, Time.now)
        audit.first.update_attribute(:user_id, logged_in_user.id)

        audit_of_ssr = AuditRecovery.where("auditable_id = '#{@ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
        audit_of_ssr.first.update_attribute(:created_at, Time.now)
        audit_of_ssr.first.update_attribute(:user_id, logged_in_user.id)
        @previously_submitted_ssrs = @sr.sub_service_requests.where.not(submitted_at: nil).to_a
        @sr.previous_submitted_at = @sr.submitted_at
      end

      it 'should send_user_notifications' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).to receive(:send_user_notifications)
        @notifier_logic.send_request_amendment_email_evaluation 
      end

      it 'should not send_request_amendment' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).not_to receive(:send_request_amendment)
        @notifier_logic.send_request_amendment_email_evaluation 
      end
    end

    context 'previously submitted ssr that has both added and deleted services' do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        
        audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
        audit.first.update_attribute(:created_at, Time.now - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)

        ssr_li_id   = @ssr.line_items.first.id
        @ssr.line_items.first.destroy!

        audit_1 = AuditRecovery.where("auditable_id = '#{ssr_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        audit_1.first.update_attribute(:created_at, Time.now - 5.hours)
        audit_1.first.update_attribute(:user_id, logged_in_user.id)

        @previously_submitted_ssrs = @sr.sub_service_requests.where.not(submitted_at: nil).to_a
        @sr.previous_submitted_at = @sr.submitted_at
      end

      it 'should send_request_amendment' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).to receive(:send_request_amendment)
        @notifier_logic.send_request_amendment_email_evaluation 
      end
    end

    context 'previously submitted ssr that has deleted services' do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        
        ssr_li_id   = @ssr.line_items.first.id
        @ssr.line_items.first.destroy!
        audit = AuditRecovery.where("auditable_id = '#{ssr_li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
        audit.first.update_attribute(:created_at, Time.now - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)
        @previously_submitted_ssrs = @sr.sub_service_requests.where.not(submitted_at: nil).to_a
        @sr.previous_submitted_at = @sr.submitted_at
      end

      it 'should send_request_amendment' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).to receive(:send_request_amendment)
        @notifier_logic.send_request_amendment_email_evaluation 
      end
    end

    context 'previously submitted SSR (existing SSR) that has added services' do
      before :each do
        @org         = create(:organization_with_process_ssrs)
        service     = create(:service, organization: @org, one_time_fee: true)
        protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
        li          = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
                      create(:service_provider, identity: logged_in_user, organization: @org)
        
        audit = AuditRecovery.where("auditable_id = '#{li_1.id}' AND auditable_type = 'LineItem' AND action = 'create'")
        audit.first.update_attribute(:created_at, Time.now.utc - 5.hours)
        audit.first.update_attribute(:user_id, logged_in_user.id)
        @previously_submitted_ssrs = @sr.sub_service_requests.where.not(submitted_at: nil).to_a
        @sr.previous_submitted_at = @sr.submitted_at
      end

      it 'should send_request_amendment' do
        @notifier_logic =  NotifierLogic.new(@sr, nil, logged_in_user)
        expect(@notifier_logic).to receive(:send_request_amendment)
        @notifier_logic.send_request_amendment_email_evaluation 
      end
    end
  end
end