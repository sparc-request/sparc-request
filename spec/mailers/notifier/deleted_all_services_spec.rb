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
  build_service_request_with_project

  let(:service3)           { create(:service,
                                    organization_id: program.id,
                                    name: 'ABCD',
                                    one_time_fee: true) }
  let(:pricing_setup)     { create(:pricing_setup,
                                    organization_id: program.id,
                                    display_date: Time.now - 1.day,
                                    federal: 50,
                                    corporate: 50,
                                    other: 50,
                                    member: 50,
                                    college_rate_type: 'federal',
                                    federal_rate_type: 'federal',
                                    industry_rate_type: 'federal',
                                    investigator_rate_type: 'federal',
                                    internal_rate_type: 'federal',
                                    foundation_rate_type: 'federal') }
  let(:pricing_map)       { create(:pricing_map,
                                    unit_minimum: 1,
                                    unit_factor: 1,
                                    service: service3,
                                    quantity_type: 'Each',
                                    quantity_minimum: 5,
                                    otf_unit_type: 'Week',
                                    display_date: Time.now - 1.day,
                                    full_rate: 2000,
                                    units_per_qty_max: 20) }
  let(:identity)          { Identity.first }
  let(:organization)      { Organization.first }
  let(:non_service_provider_org)  { create(:organization, name: 'BLAH', process_ssrs: 0, is_available: 1) }
  let(:service_provider)  { create(:service_provider,
                                    identity: identity,
                                    organization: organization,
                                    service: service3) }
  let!(:non_service_provider_ssr) { create(:sub_service_request, ssr_id: "0004", status: "submitted", service_request_id: service_request.id, organization_id: non_service_provider_org.id, org_tree_display: "SCTR1/BLAH")}

  let(:previously_submitted_at) { service_request.submitted_at.nil? ? Time.now.utc : service_request.submitted_at.utc }
  let(:audit)                   { sub_service_request.audit_report(identity,
                                                                      previously_submitted_at,
                                                                      Time.now.utc) }

  before { add_visits }

  # SUBMITTED
  before do
    service_request.update_attribute(:status, "submitted")
  end

  context 'service_provider' do
    let(:xls)                     { Array.new }
    let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        audit, true) }
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