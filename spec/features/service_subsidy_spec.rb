# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'
#include 'ServiceCalendarHelper'

RSpec.describe "subsidy page" do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  describe "has subsidy" do
    before :each do
      add_visits

      #destroy subsidies created in fixtures again...
      subsidy_map.destroy
      subsidy.destroy

      subsidy_map = create(:subsidy_map, organization_id: program.id, max_dollar_cap: (sub_service_request.direct_cost_total / 200), max_percentage: 50.00)
      program.update_attribute(:subsidy_map, subsidy_map)
      visit service_subsidy_service_request_path service_request.id
    end

    describe "is not overridden" do
      it 'should allow PI Contribution to be set', js: true do
        expect(page).not_to have_css("input.pi-contribution[disabled=disabled]")
      end

      describe "leaving the form blank" do

        it 'should be fine with that', js: true do
          find('.save-and-continue').click
          wait_for_javascript_to_finish

          expect(sub_service_request.subsidy).to eq(nil)
        end
      end

      describe "filling in with wrong values" do
        it 'should reject to high an amount', js: true do
          @total = (sub_service_request.direct_cost_total / 100)
          find('.pi-contribution').set((@total - program.subsidy_map.max_dollar_cap) - 5)
          find('.select-project-view').click
          find('.save-and-continue').click
          expect(page).to have_text("cannot exceed maximum dollar amount")
        end

        it 'should reject too high a percentage', js: true do
          @total = (sub_service_request.direct_cost_total / 100)
          #Change values, and re-visit page, to independantly test the percentage, instead of max_dollar_cap
          subsidy_map = create(:subsidy_map, organization_id: program.id, max_dollar_cap: @total, max_percentage: 50.00)
          program.update_attribute(:subsidy_map, subsidy_map)
          visit service_subsidy_service_request_path service_request.id
          find('.pi-contribution').set(@total - program.subsidy_map.max_dollar_cap)
          find('.select-project-view').click
          find('.save-and-continue').click
          expect(page).to have_text("cannot exceed maximum percentage of")
        end
      end

      describe "filling in with correct values" do
        before :each do
          @total = (sub_service_request.direct_cost_total / 100)
          @contribution = @total - program.subsidy_map.max_dollar_cap
          find('.pi-contribution').set(@contribution)
          find('.select-project-view').click
          wait_for_javascript_to_finish
        end

        it 'should save PI Contribution', js: true do
          click_link 'Save & Continue'
          wait_for_javascript_to_finish

          expect(sub_service_request.subsidy.pi_contribution).to eq((@contribution * 100).to_i)
        end

        it 'should adjust requested funding correctly', js: true do
          expect(find(".pi-contribution").value).to eq((@total - @contribution).to_s)
        end

        it 'should adjust subsidy percent correctly', js: true do
          expect(find(".subsidy_percent_#{sub_service_request.id}").text.gsub!('%', '').to_f).to eq(((@total - @contribution) / @total) * 100)
        end
      end
    end

    describe "Multiple subsidies" do
      before :each do
        subsidy_map = create(:subsidy_map, organization_id: program.id, max_dollar_cap: (sub_service_request.direct_cost_total / 200), max_percentage: 50.00)
        program.update_attribute(:subsidy_map, subsidy_map)

        program2 = create(:program,type:'Program',parent_id:provider.id,name:'Test',order:1,abbreviation:'Informatics',process_ssrs:  0, is_available: 1)
        pricing_setup2 = create(:pricing_setup, organization_id: program2.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')
        service3 = create(:service, organization_id:program2.id, name: 'Per Patient')
        subsidy_map2 = create(:subsidy_map, organization_id: program2.id, max_dollar_cap: (sub_service_request.direct_cost_total / 200), max_percentage: 50.00)
        program2.update_attribute(:subsidy_map, subsidy_map2)
        pricing_map3 = create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service3.id, display_date: Time.now - 1.day, full_rate: 2000, federal_rate: 3000, units_per_qty_max: 20)
        @ssr2 = create(:sub_service_request, ssr_id: "0001", service_request_id: service_request.id, organization_id: program2.id,status: "draft")
        line_item3 = create(:line_item, service_request_id: service_request.id, service_id: service3.id, sub_service_request_id: @ssr2.id, quantity: 0)

        service_request.reload
        add_visits
        visit service_subsidy_service_request_path service_request.id
      end
      it "should have 2 subsidies", js: true do
        @total = (sub_service_request.direct_cost_total / 100)
        find(".pi-contribution.ssr_#{sub_service_request.id}").set((@total - program.subsidy_map.max_dollar_cap) - 100)
        find('.select-project-view').click
        #find(".pi-contribution.ssr_#{@ssr2.id}").set()
        wait_for_javascript_to_finish
        find('.save-and-continue').click
        expect(page).to have_text("cannot exceed maximum dollar amount")
      end
    end

    describe 'Subsidy is overridden' do

      before { Subsidy.destroy_all }

      it 'should NOT allow PI Contribution to be set', js: true do
        create(:subsidy,
                sub_service_request_id: sub_service_request.id,
                pi_contribution: sub_service_request.direct_cost_total,
                overridden: true)

        visit service_subsidy_service_request_path service_request.id
        wait_for_javascript_to_finish

        expect(page).to have_css('input.pi-contribution[disabled=disabled]')
      end
    end
  end
end
