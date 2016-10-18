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
  let!(:non_service_provider_ssr) { create(:sub_service_request, ssr_id: "0004", status: "get_a_cost_estimate", service_request_id: service_request.id, organization_id: non_service_provider_org.id, org_tree_display: "SCTR1/BLAH")}

  let(:previously_submitted_at) { service_request.submitted_at.nil? ? Time.now.utc : service_request.submitted_at.utc }
  let(:audit)                   { sub_service_request.audit_report(identity,
                                                                      previously_submitted_at,
                                                                      Time.now.utc) }

  before { add_visits }

  # GET A COST ESTIMATE
  before do
    service_request.update_attribute(:status, "get_a_cost_estimate")
  end

  context 'service_provider' do
    before do
      create(:note_without_validations,
            identity_id:  identity.id, 
            notable_id: service_request.id)
    end
    let(:xls)                     { Array.new }
    let(:mail)                    { Notifier.notify_service_provider(service_provider,
                                                                        service_request,
                                                                        xls,
                                                                        identity,
                                                                        audit) }
    # Expected service provider message is defined under get_a_cost_estimate_service_provider_admin_message
    it 'should display service_provider intro message, link, conclusion, and should not display acknowledgments' do
      get_a_cost_estimate_intro_for_service_providers
    end

    it 'should render default tables' do
      assert_notification_email_tables_for_service_provider
    end

    it 'should NOT have a notes reminder message' do
      get_a_cost_estimate_does_not_have_notes(mail)
    end

    context 'when protocol has selected for epic' do
      before do
        service_request.protocol.update_attribute(:selected_for_epic, true)
      end

      it 'should show epic column' do
        assert_email_user_information_when_selected_for_epic(mail.body)
      end
    end

    context 'when protocol is not selected for epic' do

      before do
        service_request.protocol.update_attribute(:selected_for_epic, false)
      end

      it 'should not show epic column' do
        assert_email_user_information_when_not_selected_for_epic(mail.body)
      end
    end
  end

  context 'users' do
    before do
      create(:note_without_validations,
            identity_id:  identity.id, 
            notable_id: service_request.id)
    end
    let(:xls)                     { ' ' }
    let(:project_role)            { service_request.protocol.project_roles.select{ |role| role.project_rights != 'none' && !role.identity.email.blank? }.first }
    let(:approval)                { service_request.approvals.create }
    let(:mail)                    { Notifier.notify_user(project_role,
                                                            service_request,
                                                            xls,
                                                            approval,
                                                            identity
                                                            ) }
    # Expected user message is defined under get_a_cost_estimate_general_users
    it 'should have user intro message, conclusion, and acknowledgments' do
      get_a_cost_estimate_intro_for_general_users
    end

    it 'should render default tables' do
      assert_notification_email_tables_for_user
    end

    it 'should NOT have a notes reminder message' do
      get_a_cost_estimate_does_not_have_notes(mail.body.parts.first.body)
    end

    context 'when protocol has selected for epic' do

      before do
        service_request.protocol.update_attribute(:selected_for_epic, true)
      end

      it 'should show epic column' do
        assert_email_user_information_when_selected_for_epic(mail.body.parts.first.body)
      end
    end

    context 'when protocol is not selected for epic' do

      before do
        service_request.protocol.update_attribute(:selected_for_epic, false)
      end

      it 'should not show epic column' do
        assert_email_user_information_when_not_selected_for_epic(mail.body.parts.first.body)
      end
    end
  end

  context 'admin' do
    before do
      create(:note_without_validations,
            identity_id:  identity.id, 
            notable_id: service_request.id)
    end
    let(:xls)                       { ' ' }
    let!(:submission_email) { create(:submission_email, 
                                      email: 'success@musc.edu', 
                                      organization_id: organization.id) }
    
    let(:mail)                      { Notifier.notify_admin(service_request,
                                                              submission_email,
                                                              xls,
                                                              identity,
                                                              service_request.protocol.sub_service_requests.first) }
    # Expected admin message is defined under get_a_cost_estimate_service_provider_admin_message
    it 'should display admin intro message, link, conclusion, and should not display acknowledgments' do
      get_a_cost_estimate_intro_for_admin
    end

    it 'should render default tables' do
      service_request.protocol.sub_service_requests.first.update_attribute(:organization_id, organization.id)
      assert_notification_email_tables_for_admin
    end

    it 'should NOT have a notes reminder message' do
      get_a_cost_estimate_does_not_have_notes(mail.body.parts.first.body)
    end

    context 'when protocol has selected for epic' do

      before do
        service_request.protocol.update_attribute(:selected_for_epic, true)
      end

      it 'should show epic column' do
        assert_email_user_information_when_selected_for_epic(mail.body.parts.first.body)
      end
    end

    context 'when protocol is not selected for epic' do

      before do
        service_request.protocol.update_attribute(:selected_for_epic, false)
      end

      it 'should not show epic column' do
        assert_email_user_information_when_not_selected_for_epic(mail.body.parts.first.body)
      end
    end
  end
end
