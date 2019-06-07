# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe 'User interacts with Template tab', js: true do
  let_there_be_lane
  fake_login_for_each_test

  scenario 'and sees the tab rendered in the first place (.html action)' do
    org       = create(:organization)
                create(:pricing_setup, organization: org)
    service   = create(:service, organization: org, pricing_map_count: 1)
    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, protocol: protocol)
    ssr       = create(:sub_service_request, service_request: @sr, organization: org)
    li        = create(:line_item, sub_service_request: ssr, service_request: @sr, service: service)
    @arm      = create(:arm, protocol: protocol)
    vg        = create(:visit_group, arm: @arm)
    liv       = create(:line_items_visit, line_item: li, arm: @arm)
    visit     = create(:visit, line_items_visit: liv, visit_group: vg)

    visit service_calendar_service_request_path(srid: @sr.id)
    wait_for_javascript_to_finish

    click_link 'Template Tab'
    wait_for_javascript_to_finish

    expect(page).to have_selector('#service-calendars', visible: true)
  end

  context 'with pppv services' do
    scenario 'and sees pppv calendar(s)' do
      org       = create(:organization)
                  create(:pricing_setup, organization: org)
      service   = create(:per_patient_per_visit_service, organization: org, pricing_map_count: 1)
      protocol  = create(:protocol_federally_funded, primary_pi: jug2)
      @sr       = create(:service_request_without_validations, protocol: protocol)
      ssr       = create(:sub_service_request, service_request: @sr, organization: org)
      li        = create(:line_item, sub_service_request: ssr, service_request: @sr, service: service)
      @arm      = create(:arm, protocol: protocol)
      vg        = create(:visit_group, arm: @arm)
      liv       = create(:line_items_visit, line_item: li, arm: @arm)
      visit     = create(:visit, line_items_visit: liv, visit_group: vg)

      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'Template Tab'
      wait_for_javascript_to_finish

      expect(page).to have_text("Clinical Services Arm: #{@arm.name}", normalize_ws: true)
    end
  end

  context 'with otf services' do
    scenario 'and sees the otf calendar' do
      org       = create(:organization)
                  create(:pricing_setup, organization: org)
      service   = create(:one_time_fee_service, organization: org, pricing_map_count: 1)
      protocol  = create(:protocol_federally_funded, primary_pi: jug2)
      @sr       = create(:service_request_without_validations, protocol: protocol)
      ssr       = create(:sub_service_request, service_request: @sr, organization: org)
      li        = create(:line_item, sub_service_request: ssr, service_request: @sr, service: service)
      @arm      = create(:arm, protocol: protocol)
      vg        = create(:visit_group, arm: @arm)
      liv       = create(:line_items_visit, :without_validations, line_item: li, arm: @arm)
      visit     = create(:visit, line_items_visit: liv, visit_group: vg)

      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'Template Tab'
      wait_for_javascript_to_finish

      expect(page).to have_selector('.panel-title', text: "Non-clinical Services")
    end
  end

  context 'and causes the tab to be rerendered (.js action)' do
    scenario 'and sees the tab is rendered correctly' do
      org       = create(:organization)
                  create(:pricing_setup, organization: org)
      service   = create(:service, organization: org, pricing_map_count: 1)
      protocol  = create(:protocol_federally_funded, primary_pi: jug2)
      @sr       = create(:service_request_without_validations, protocol: protocol)
      ssr       = create(:sub_service_request, service_request: @sr, organization: org)
      li        = create(:line_item, sub_service_request: ssr, service_request: @sr, service: service)
      @arm      = create(:arm, protocol: protocol)
      vg        = create(:visit_group, arm: @arm)
      liv       = create(:line_items_visit, line_item: li, arm: @arm)
      visit     = create(:visit, line_items_visit: liv, visit_group: vg)

      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'Template Tab'
      wait_for_javascript_to_finish

      find("#visits-select-for-#{@arm.id} + .dropdown-toggle").click
      all(".dropdown-menu.open a")[1].click
      wait_for_javascript_to_finish

      expect(page).to have_selector('#service-calendars', visible: true)
    end
  end
end
