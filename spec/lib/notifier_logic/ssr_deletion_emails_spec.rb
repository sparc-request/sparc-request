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

  context '#ssr_deletion_emails(ssr, ssr_destroyed: true, request_amendment: false) for an entire SR' do
    context 'deleted an entire SSR' do
      before :each do
        service_requester     = create(:identity)
        ### SR SETUP ###
        ### PREVIOUSLY SUBMITTED SSR ###
        @org         = create(:organization_with_process_ssrs)
        @org2        = create(:organization_with_process_ssrs)
        ### ADMIN EMAIL ###
        @org2.submission_emails.create(email: 'hedwig@owlpost.com')
        @admin_email = 'hedwig@owlpost.com'
        service      = create(:service, organization: @org, one_time_fee: true, pricing_map_count: 1)
        protocol     = create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study')
        @sr          = create(:service_request_without_validations, protocol: protocol, submitted_at: Time.now.yesterday.utc)
        ### SSR SETUP ###
        @ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org2, status: 'submitted', submitted_at: Time.now.yesterday.utc, service_requester: service_requester)
        ssr2         = create(:sub_service_request_without_validations, service_request: @sr, organization: @org, status: 'submitted', submitted_at: Time.now.yesterday.utc)
        ### LINE ITEM SETUP ###
        li           = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
        li_1         = create(:line_item, service_request: @sr, sub_service_request: ssr2, service: service)
        @service_provider = create(:service_provider, identity: logged_in_user, organization: @org2)
        ### DELETE LINE ITEM WHICH IN TURNS DELETES SSR ###
        # mimics the service_requests_controller remove_service method
        @destroyed_li_id = li.id
        li.destroy
        @ssr.update_attribute(:status, 'draft')
        @sr.reload
        ### DELETES AN ENTIRE SSR AND SETS UP ASSOCIATED AUDIT ###
        delete_entire_ssr(@sr, @ssr, ssr2)
      end

      it 'should not notify authorized users (deletion email)' do
        allow(Notifier).to receive(:notify_user) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver_now)
          mailer
        end
        NotifierLogic.new(@sr, logged_in_user).ssr_deletion_emails(deleted_ssr: @ssr, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
        expect(Notifier).not_to have_received(:notify_user)
      end

      it 'should notify service providers (deletion email)' do
        allow(Notifier).to receive(:notify_service_provider) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver_now)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).ssr_deletion_emails(deleted_ssr: @ssr, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
        expect(Notifier).to have_received(:notify_service_provider).with(@service_provider, @sr, logged_in_user, @ssr, nil, true, false)
      end

      it 'should notify admin (deletion email)' do
        allow(Notifier).to receive(:notify_admin) do
          mailer = double('mail')
          expect(mailer).to receive(:deliver_now)
          mailer
        end

        NotifierLogic.new(@sr, logged_in_user).ssr_deletion_emails(deleted_ssr: @ssr, ssr_destroyed: true, request_amendment: false, admin_delete_ssr: false)
        expect(Notifier).to have_received(:notify_admin).with(@admin_email, logged_in_user, @ssr, nil, true)
      end
    end
  end

  def delete_entire_ssr(sr, ssr, ssr2)
    ### Setting up audits for emails ###
    ### Changing time for the created_at, so this SSR does not show up in audit ###
    audit_of_ssr_create = AuditRecovery.where("auditable_id = '#{ssr.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)

    audit_of_ssr2_create = AuditRecovery.where("auditable_id = '#{ssr2.id}' AND auditable_type = 'SubServiceRequest' AND action = 'create'")
    audit_of_ssr2_create.first.update_attribute(:created_at, Time.now.yesterday.utc - 5.hours)
    ### Deleted LIs since previously submitted ###
    deleted_li = AuditRecovery.where("audited_changes LIKE '%sub_service_request_id: #{ssr.id}%' AND auditable_type = 'LineItem' AND action IN ('destroy')")
    deleted_li.first.update_attribute(:created_at, Time.now.utc - 5.hours)
    deleted_li.first.update_attribute(:user_id, logged_in_user.id)

    sr.previous_submitted_at = sr.submitted_at
  end
end
