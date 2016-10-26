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

  before { add_visits }

  # SUBMITTED
  before :each do
    service_request.update_attribute(:submitted_at, Time.now.yesterday)
    service_request.sub_service_requests.each do |ssr|
      ssr.update_attribute(:submitted_at, Time.now.yesterday)
      ssr.update_attribute(:status, 'submitted')
      li_id = ssr.line_items.first.id
      ssr.line_items.first.destroy!
      ssr.save!
      service_request.reload
      @audit = AuditRecovery.where("auditable_id = '#{li_id}' AND auditable_type = 'LineItem' AND action = 'destroy'")
    end
    
    @audit.first.update_attribute(:created_at, Time.now - 5.hours)
    @audit.first.update_attribute(:user_id, identity.id)
    @report = service_request.sub_service_requests.first.audit_report(identity, Time.now.yesterday - 4.hours, Time.now.tomorrow)
  end

  context 'service_provider' do
    let(:xls)                     { Array.new }
    let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        service_request.sub_service_requests.first,
                                                                        @report, true) }
    # Expected service provider message is defined under deleted_all_services_intro_for_service_providers
    it 'should display service provider intro message, conclusion, link, and should not display acknowledgments' do
      deleted_all_services_intro_for_service_providers(mail)
    end

    it 'should render default tables' do
      assert_notification_email_tables_for_service_provider_with_all_services_deleted
    end

    it 'should have a notes reminder message but not a submission reminder' do
      does_not_have_a_reminder_note(mail)
      does_not_have_a_submission_reminder(mail)
    end

    it 'should not have audited information table' do
      expect(mail).not_to have_xpath("//th[text()='Service']/following-sibling::th[text()='Action']")
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