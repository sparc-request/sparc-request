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
  describe '#pppv_line_items_visits_to_display(arm, service_request, sub_service_request, opts = {})' do
    before :each do
      @arm  = create(:arm_without_validations)
      org_C = create(:organization, process_ssrs: false, abbreviation: "C")
      org_B = create(:organization, process_ssrs: true, abbreviation: "B", parent: org_C)
      org_A = create(:organization, process_ssrs: false, abbreviation: "A", parent: org_B)
      @sr   = create(:service_request_without_validations)
      @ssr  = create(:sub_service_request, service_request: @sr, organization: org_C, status: "not_draft")

      service_pppv = create(:service, :without_validations, organization: org_A, one_time_fee: false)
      service_otf  = create(:service, :without_validations, organization: org_A, one_time_fee: true)

      # this LIV should not appear (it is not PPPV)
      li_otf = create(:line_item, :without_validations, service: service_otf, service_request: @sr, sub_service_request: @ssr)

      # this LIV should not appear (associated with another Arm)
      wrong_arm         = create(:arm, :without_validations)
      li_pppv_wrong_arm = create(:line_item, :without_validations, service: service_pppv, service_request: @sr, sub_service_request: @ssr)
      liv_wrong_arm     = create(:line_items_visit, arm: wrong_arm, line_item: li_pppv_wrong_arm)
                          create(:visit, line_items_visit: liv_wrong_arm, research_billing_qty: 1)

      # expect these LIVs to appear
      li_pppv     = create(:line_item, :without_validations, service: service_pppv, sub_service_request: @ssr, service_request: @sr)
      @liv_pppv1  = create(:line_items_visit, arm: @arm, line_item: li_pppv)
      @liv_pppv2  = create(:line_items_visit, arm: @arm, line_item: li_pppv)
                    create(:visit, line_items_visit: @liv_pppv1, research_billing_qty: 1)
                    create(:visit, line_items_visit: @liv_pppv2, research_billing_qty: 1)

      # Draft LIV is conditional
      @draft_ssr    = create(:sub_service_request, :without_validations, service_request: @sr, organization: org_A, status: "draft")
      li_pppv_draft = create(:line_item, :without_validations, service: service_pppv, service_request: @sr, sub_service_request: @draft_ssr)
      @liv_draft    = create(:line_items_visit, arm: @arm, line_item: li_pppv_draft)
                      create(:visit, line_items_visit: @liv_draft, research_billing_qty: 1)

      # First Draft LIV is conditional
      @first_draft_ssr    = create(:sub_service_request, :without_validations, service_request: @sr, organization: org_A, status: "first_draft")
      li_pppv_first_draft = create(:line_item, :without_validations, service: service_pppv, sub_service_request: @first_draft_ssr)
      @liv_first_draft    = create(:line_items_visit, arm: @arm, line_item: li_pppv_first_draft)
                            create(:visit, line_items_visit: @liv_first_draft, research_billing_qty: 1)

      # Unchecked LIV
      @liv_unchecked  = create(:line_items_visit, arm: @arm, line_item: li_pppv)
                        create(:visit, line_items_visit: @liv_unchecked, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)

      @other_ssr        = create(:sub_service_request, service_request: @sr, organization: org_C, status: "not_draft")
      li_pppv_other_ssr = create(:line_item, :without_validations, service: service_pppv, sub_service_request: @other_ssr, service_request: @sr)
      @liv_other_ssr    = create(:line_items_visit, arm: @arm, line_item: li_pppv_other_ssr)
                          create(:visit, line_items_visit: @liv_other_ssr, research_billing_qty: 1)

      @arm.reload
      @ssr.reload
    end

    context 'opts[:merged] == true' do
      context 'opts[:consolidated] == true' do
        context 'opts[:show_draft] == true' do
          it 'should exclude first_draft SSRs' do
            livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, @ssr, merged: true, consolidated: true, show_draft: true)

            expect(livs.keys).to contain_exactly(@ssr, @draft_ssr, @other_ssr)
            expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2)
            expect(livs[@draft_ssr]).to contain_exactly(@liv_draft)
            expect(livs[@other_ssr]).to contain_exactly(@liv_other_ssr)
          end
        end

        context 'opts[:show_draft] == false' do
          it 'should exclude first_draft and draft SSRs' do
            livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, @ssr, merged: true, consolidated: true, show_draft: false)

            expect(livs.keys).to contain_exactly(@ssr, @other_ssr)
            expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2)
            expect(livs[@other_ssr]).to contain_exactly(@liv_other_ssr)
          end
        end
      end

      context 'opts[:consolidated] == false' do
        it 'should include all SSRs' do
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, @ssr, merged: true, consolidated: false)

          expect(livs.keys).to contain_exactly(@ssr, @draft_ssr, @first_draft_ssr, @other_ssr)
          expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2)
          expect(livs[@draft_ssr]).to contain_exactly(@liv_draft)
          expect(livs[@first_draft_ssr]).to contain_exactly(@liv_first_draft)
          expect(livs[@other_ssr]).to contain_exactly(@liv_other_ssr)
        end
      end

      context 'opts[:show_unchecked] == true' do
        it 'should not filter out unchecked visits' do
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, @ssr, merged: true, consolidated: true, show_draft: false, show_unchecked: true)

          expect(livs.keys).to contain_exactly(@ssr, @other_ssr)
          expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2, @liv_unchecked)
          expect(livs[@other_ssr]).to contain_exactly(@liv_other_ssr)
        end
      end

      context 'opts[:show_unchecked] == false' do
        it 'should filter out unchecked visits' do
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, @ssr, merged: true, consolidated: true, show_draft: false, show_unchecked: false)

          expect(livs.keys).to contain_exactly(@ssr, @other_ssr)
          expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2)
          expect(livs[@other_ssr]).to contain_exactly(@liv_other_ssr)
        end
      end
    end

    context 'opts[:merged] == false' do
      context "sub_service_request present" do
        it "should return the SSRs line items" do
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, @ssr, merged: false)

          expect(livs.keys).to contain_exactly(@ssr)
          expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2, @liv_unchecked)
        end
      end

      context "sub_service_request not present" do
        it "should return line items for all SSRs" do
          livs = Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(@arm, @sr, nil, merged: false)

          expect(livs.keys).to contain_exactly(@ssr, @draft_ssr, @other_ssr)
          expect(livs[@ssr]).to contain_exactly(@liv_pppv1, @liv_pppv2, @liv_unchecked)
          expect(livs[@draft_ssr]).to contain_exactly(@liv_draft)
          expect(livs[@other_ssr]).to contain_exactly(@liv_other_ssr)
        end
      end
    end
  end
end
