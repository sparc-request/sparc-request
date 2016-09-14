# coding: utf-8
# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe "calender totals", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()
  let!(:line_item3) { create(:line_item, id: 123456789, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }


  before :each do
    service_request.reload
    visit root_path
    visit service_calendar_service_request_path service_request.id
    arm1.reload
    arm2.reload
  end

  describe "one time fees" do

    it "should calculate the totals", js: true do
      expect(find(".total_#{line_item3.id}")).to have_exact_text("$50.00") # 5 quantity 1 unit per
    end
  end

  describe "display rates" do

    it "should show the full rate when full rate > your cost", js: true do
      expect(find(".service_rate_#{line_item3.id}")).to have_exact_text("$20.00")
    end
  end

  describe "displaying totals" do
    it "totals should be 0 when visits aren't checked", js: true do
      wait_for_javascript_to_finish
      expect(first(".pp_max_total_direct_cost").text()).to have_exact_text("$0.00")
      if USE_INDIRECT_COST
        expect(find(".pp_total_indirect_cost").text()).to have_exact_text("$0.00")
      end
      expect(first(".pp_total").text()).to have_exact_text("$0.00")
    end

    it "should update total costs when a visit is checked", js: true do
      visit_id = arm1.line_items_visits.first.visits[1].id
      page.check("visits_#{visit_id}")
      wait_for_javascript_to_finish
      expect(first(".total_#{arm1.line_items_visits.first.id}")).to have_exact_text("$30.00")
    end

    # Not sure if we're keeping the arrows. Commenting this out for now.
    # it "should change visits when -> is clicked", js: true do
    #   click_link("->")
    #   retry_until {
    #     find("#arm_#{arm1.id}_visit_name_6").should have_value("Visit 6")
    #   }
    # end
  end
end
