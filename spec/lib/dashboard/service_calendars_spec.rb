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

RSpec.describe Dashboard::ServiceCalendars do
  describe '.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, opts = {})' do
    context 'opts[:merged] == true' do
      it "should return PPPV LIV's of arm not associated with a first-draft SSR" do
        arm = create(:arm_without_validations)
        org_C = create(:organization, process_ssrs: false, abbreviation: "C")
        org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
        org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
        ssr = create(:sub_service_request, organization: org_C, status: "not_draft")

        # expect this LIV to appear
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
        liv_pppv1 = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: ssr)
        liv_pppv2 = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: ssr)
        create(:visit, line_items_visit_id: liv_pppv1.id, research_billing_qty: 1)
        create(:visit, line_items_visit_id: liv_pppv2.id, research_billing_qty: 1)

        # this LIV should not appear (it is not PPPV)
        service_otf = create(:service, :without_validations, organization: org_A, one_time_fee: true)
        li_otf = create(:line_item, :without_validations, service: service_otf, sub_service_request: ssr)

        # this LIV should not appear (not associated with arm)
        wrong_arm = create(:arm, :without_validations)
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
        liv_not_associated_with_arm = create(:line_items_visit, arm: wrong_arm, line_item: li_pppv, sub_service_request: ssr)
        create(:visit, line_items_visit_id: liv_not_associated_with_arm.id, research_billing_qty: 1)

        # this LIV should appear (associated with draft SSR)
        draft_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "draft")
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: draft_ssr)
        liv_draft = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: draft_ssr)
        create(:visit, line_items_visit_id: liv_draft.id, research_billing_qty: 1)

        # this LIV should not appear (associated with first-draft SSR)
        first_draft_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "first_draft")
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: first_draft_ssr)
        liv_associated_with_first_draft = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: first_draft_ssr)
        create(:visit, line_items_visit_id: liv_associated_with_first_draft.id, research_billing_qty: 1)

        # this LIV should not appear (not 'chosen' - research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
        not_chosen_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "draft")
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: not_chosen_ssr)
        liv_not_chosen = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: not_chosen_ssr)
        create(:visit, line_items_visit_id: liv_not_chosen.id, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)

        arm.reload
        livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, nil, ssr, merged: true, consolidated: false, display_all_services: false)
        expect(livs.keys).to contain_exactly(draft_ssr, ssr)
        expect(livs[draft_ssr]).to eq([liv_draft])
        expect(livs[ssr]).to contain_exactly(liv_pppv1, liv_pppv2)
      end
    end

    context 'opts[:merged] == true' do
      context 'opts[:display_all_services] == true' do
        it "should return PPPV LIV's of arm not associated with a first-draft SSR" do
          arm = create(:arm_without_validations)
          org_C = create(:organization, process_ssrs: false, abbreviation: "C")
          org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
          org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
          ssr = create(:sub_service_request, organization: org_C, status: "not_draft")

          # expect this LIV to appear
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
          liv_pppv1 = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: ssr)
          liv_pppv2 = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: ssr)
          create(:visit, line_items_visit_id: liv_pppv1.id, research_billing_qty: 1)
          create(:visit, line_items_visit_id: liv_pppv2.id, research_billing_qty: 1)

          # this LIV should not appear (it is not PPPV)
          service_otf = create(:service, :without_validations, organization: org_A, one_time_fee: true)
          li_otf = create(:line_item, :without_validations, service: service_otf, sub_service_request: ssr)

          # this LIV should not appear (not associated with arm)
          wrong_arm = create(:arm, :without_validations)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
          liv_not_associated_with_arm = create(:line_items_visit, arm: wrong_arm, line_item: li_pppv, sub_service_request: ssr)
          create(:visit, line_items_visit_id: liv_not_associated_with_arm.id, research_billing_qty: 1)

          # this LIV should appear (associated with draft SSR)
          draft_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "draft")
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: draft_ssr)
          liv_draft = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: draft_ssr)
          create(:visit, line_items_visit_id: liv_draft.id, research_billing_qty: 1)

          # this LIV should not appear (associated with first-draft SSR)
          first_draft_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "first_draft")
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: first_draft_ssr)
          liv_associated_with_first_draft = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: first_draft_ssr)
          create(:visit, line_items_visit_id: liv_associated_with_first_draft.id, research_billing_qty: 1)

          # this LIV should appear (not 'chosen' - research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
          not_chosen_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "draft")
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: not_chosen_ssr)
          liv_not_chosen = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: not_chosen_ssr)
          create(:visit, line_items_visit_id: liv_not_chosen.id, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)

          arm.reload
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, nil, ssr, merged: true, consolidated: false, display_all_services: true)

          expect(livs.keys).to contain_exactly(draft_ssr, ssr, not_chosen_ssr)
          expect(livs[draft_ssr]).to eq([liv_draft])
          expect(livs.values.flatten).to contain_exactly(liv_pppv1, liv_pppv2, liv_draft, liv_not_chosen)
        end
      end
    end

    context 'opts[:merged] == false' do
      context "sub_service_request present" do
        it "should return PPPV LIV's of sub_service_request also belonging to arm" do
          arm = create(:arm_without_validations)
          org_C = create(:organization, process_ssrs: false, abbreviation: "C")
          org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
          org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
          ssr = create(:sub_service_request, organization: org_C)

          # expect these LIV's to appear
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
          liv_pppv1 = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: ssr)
          liv_pppv2 = create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: ssr)

          # this LIV should not appear (it is not PPPV)
          service_otf = create(:service, :without_validations, organization: org_A, one_time_fee: true)
          li_otf = create(:line_item, :without_validations, service: service_otf, sub_service_request: ssr)

          # this LIV should not appear (associated with another SSR)
          another_ssr = create(:sub_service_request, :without_validations, organization: org_A)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: another_ssr)
          create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: another_ssr)

          # this LIV should not appear (associated with another Arm)
          wrong_arm = create(:arm, :without_validations)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
          create(:line_items_visit, arm: wrong_arm, line_item: li_pppv, sub_service_request: ssr)

          arm.reload
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, nil, ssr)
          expect(livs.keys).to eq([ssr])
          expect(livs[ssr]).to contain_exactly(liv_pppv1, liv_pppv2)
        end
      end

      context "sub_service_request not present" do
        it "should return PPPV LIV's of sub_service_request also belonging to arm" do
          arm = create(:arm_without_validations)
          org_C = create(:organization, process_ssrs: false, abbreviation: "C")
          org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
          org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
          sr = create(:service_request_without_validations)
          ssr = create(:sub_service_request, service_request_id: sr.id, organization_id: org_A.id)

          # expect these LIV's to appear
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, service_request: sr, sub_service_request: ssr)
          liv_pppv1 = create(:line_items_visit, arm: arm, line_item: li_pppv)
          liv_pppv2 = create(:line_items_visit, arm: arm, line_item: li_pppv)

          # this LIV should not appear (it is not PPPV)
          service_otf = create(:service, :without_validations, organization: org_A, one_time_fee: true)
          li_otf = create(:line_item, :without_validations, service: service_otf, service_request: sr, sub_service_request: ssr)

          # this LIV should not appear (associated with another SR)
          another_sr = create(:service_request_without_validations)
          another_ssr = create(:sub_service_request, service_request_id: another_sr.id, organization_id: org_A.id)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, service_request: another_sr, sub_service_request: another_ssr)
          create(:line_items_visit, arm: arm, line_item: li_pppv)

          # this LIV should not appear (associated with another Arm)
          wrong_arm = create(:arm, :without_validations)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, service_request: sr, sub_service_request: ssr)
          create(:line_items_visit, arm: wrong_arm, line_item: li_pppv)

          arm.reload
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, sr, nil)

          expect(livs.keys).to eq([ssr])
          expect(livs[ssr]).to contain_exactly(liv_pppv1, liv_pppv2)
        end
      end
    end
  end
end
