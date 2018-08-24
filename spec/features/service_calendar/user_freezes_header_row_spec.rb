# Copyright © 2011-2018 MUSC Foundation for Research Development
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
# Line Item notes are for PPPV
RSpec.describe 'User freezes header row', js: true do
  let_there_be_lane

  fake_login_for_each_test

  context 'when line items + ssrs <= 8' do

    before :each do
      # 1 SSR + 7 Line items = 8
      # Do not show "Freeze Header Row" button
      org       = create(:organization)
                  create(:pricing_setup, organization: org)
      services = []
      7.times do
        services << create(:service, organization: org, one_time_fee: true, pricing_map_count: 1)
      end

      protocol  = create(:protocol_federally_funded, primary_pi: jug2)
      @sr       = create(:service_request_without_validations, protocol: protocol)
      @ssr      = create(:sub_service_request, service_request: @sr, organization: org)

      services.each do |service| 
        create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
      end
      
      arm       = create(:arm, protocol: protocol)
      vg        = create(:visit_group, arm: arm)
    end

    scenario 'does NOT see Freeze Header Row Button' do
      visit service_calendar_service_request_path(@sr)
      wait_for_javascript_to_finish
      expect(page).not_to have_selector(".freeze-header-button")
    end
  end

  context 'when line items + ssrs > 8' do

    before :each do
      # 1 SSR + 8 Line items = 9
      # Show "Freeze Header Row" button
      org       = create(:organization)
                  create(:pricing_setup, organization: org)
      services = []
      10.times do
        services << create(:service, organization: org, one_time_fee: true, pricing_map_count: 1)
      end

      protocol  = create(:protocol_federally_funded, primary_pi: jug2)
      @sr       = create(:service_request_without_validations, protocol: protocol)
      @ssr      = create(:sub_service_request, service_request: @sr, organization: org)

      services.each do |service| 
        create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
      end
      
      arm       = create(:arm, protocol: protocol)
      vg        = create(:visit_group, arm: arm)

      visit service_calendar_service_request_path(@sr)
      wait_for_javascript_to_finish
    end

    scenario 'sees Freeze Header Row Button' do
      expect(page).to have_selector(".freeze-header-button")
      expect(page).to have_selector(".freeze")
      expect(page).not_to have_selector(".scrolling-thead")
      expect(page).not_to have_selector(".scrolling-div")
      expect(page).not_to have_selector(".scrolling-table")
    end

    context "clicks Freeze Header Row Button" do
      scenario 'sees scrollable-div' do
        find(".freeze-header-button").click
        expect(page).to have_selector(".unfreeze")
        expect(page).to have_selector(".scrolling-thead")
        expect(page).to have_selector(".scrolling-div")
        expect(page).to have_selector(".scrolling-table")
      end
    end

    context "unclicks Freeze Header Row Button" do
      scenario 'does not see scrollable-div' do
        find(".freeze-header-button").click
        find(".freeze-header-button").click
        expect(page).to have_selector(".freeze")
        expect(page).not_to have_selector(".scrolling-thead")
        expect(page).not_to have_selector(".scrolling-div")
        expect(page).not_to have_selector(".scrolling-table")
      end
    end
  end
end