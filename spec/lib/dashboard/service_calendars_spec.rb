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

RSpec.describe Dashboard::ServiceCalendars do
  describe '.display_organization_hierarchy(line_items_visit)' do
    context "LIV belongs to A which belongs to B which belongs to C, where A, B, and C are not process-ssrs Organizations" do
      it "should return: C > B > A" do
        org_C = create(:organization, process_ssrs: false, abbreviation: "C")
        org_B = create(:organization, process_ssrs: false, abbreviation: "B", parent: org_C)
        org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
        service = create(:service, :without_validations, organization: org_A)
        liv = instance_double(LineItemsVisit)
        allow(liv).to receive_message_chain(:line_item, :service).
          and_return(service)

        expect(Dashboard::ServiceCalendars.display_organization_hierarchy(liv)).
          to eq("C > B > A")
      end
    end

    context "LIV belongs to A which belongs to B which belongs to C, where A and C are not  process-ssrs Organizations but B is" do
      it "should return: B > A" do
        org_C = create(:organization, process_ssrs: false, abbreviation: "C")
        org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
        org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
        service = create(:service, :without_validations, organization: org_A)
        liv = instance_double(LineItemsVisit)
        allow(liv).to receive_message_chain(:line_item, :service).
          and_return(service)

        expect(Dashboard::ServiceCalendars.display_organization_hierarchy(liv)).
          to eq("B > A")
      end
    end
  end

  describe '.pppv_line_items_visits_to_display(arm, service_request, sub_service_request, opts = {})' do
    context 'opts[:merged] == true' do
      it "should return PPPV LIV's of arm not associated with a (first-)draft SSR" do
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

        # this LIV should not appear (it is not PPPV)
        service_otf = create(:service, :without_validations, organization: org_A, one_time_fee: true)
        li_otf = create(:line_item, :without_validations, service: service_otf, sub_service_request: ssr)
        create(:line_items_visit, arm: arm, line_item: li_otf, sub_service_request: ssr)

        # this LIV should not appear (not associated with arm)
        wrong_arm = create(:arm, :without_validations)
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: ssr)
        create(:line_items_visit, arm: wrong_arm, line_item: li_pppv, sub_service_request: ssr)

        # this LIV should not appear (associated with draft SSR)
        draft_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "draft")
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: draft_ssr)
        create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: draft_ssr)

        # this LIV should not appear (associated with first-draft SSR)
        first_draft_ssr = create(:sub_service_request, :without_validations, organization: org_A, status: "first_draft")
        service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
        li_pppv = create(:line_item, :without_validations, service: service_pppv, sub_service_request: first_draft_ssr)
        create(:line_items_visit, arm: arm, line_item: li_pppv, sub_service_request: first_draft_ssr)

        arm.reload
        expect(Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, nil, ssr, merged: true)).
          to eq({ "B > A" => [liv_pppv1, liv_pppv2] })
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
          create(:line_items_visit, arm: arm, line_item: li_otf, sub_service_request: ssr)

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
          expect(Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, nil, ssr)).
            to eq({ "B > A" => [liv_pppv1, liv_pppv2] })
        end
      end

      context "sub_service_request not present" do
        it "should return PPPV LIV's of sub_service_request also belonging to arm" do
          arm = create(:arm_without_validations)
          org_C = create(:organization, process_ssrs: false, abbreviation: "C")
          org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
          org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
          sr = create(:service_request_without_validations)

          # expect this LIV to appear
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, service_request: sr)
          liv_pppv1 = create(:line_items_visit, arm: arm, line_item: li_pppv)
          liv_pppv2 = create(:line_items_visit, arm: arm, line_item: li_pppv)

          # this LIV should not appear (it is not PPPV)
          service_otf = create(:service, :without_validations, organization: org_A, one_time_fee: true)
          li_otf = create(:line_item, :without_validations, service: service_otf)
          create(:line_items_visit, arm: arm, line_item: li_otf)

          # this LIV should not appear (associated with another SR)
          another_sr = create(:service_request_without_validations)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, service_request: another_sr)
          create(:line_items_visit, arm: arm, line_item: li_pppv)

          # this LIV should not appear (associated with another Arm)
          wrong_arm = create(:arm, :without_validations)
          service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
          li_pppv = create(:line_item, :without_validations, service: service_pppv, service_request: sr)
          create(:line_items_visit, arm: wrong_arm, line_item: li_pppv)

          arm.reload
          expect(Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(arm, sr, nil)).
            to eq({ "B > A" => [liv_pppv1, liv_pppv2] })
        end
      end
    end
  end
end
