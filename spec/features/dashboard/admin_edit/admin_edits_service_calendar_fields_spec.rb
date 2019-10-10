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

RSpec.describe 'User sets each Service Calendar field', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization, admin: jug2, service_provider: jug2, process_ssrs: true)
    pricing   = create(:pricing_setup, organization: org)
    pppv      = create(:service, organization: org, one_time_fee: false, pricing_map_count: 1)
    otf       = create(:service, organization: org, one_time_fee: true, pricing_map_count: 1)
    otf.pricing_maps.first.update_attributes(otf_unit_type: 'total')

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    sr        = create(:service_request_without_validations, protocol: protocol)
    ssr       = create(:sub_service_request, service_request: sr, organization: org)
    @pppv_li  = create(:line_item, service_request: sr, sub_service_request: ssr, service: pppv)
    @otf_li   = create(:line_item, service_request: sr, sub_service_request: ssr, service: otf, units_per_quantity: 1, quantity: 1)

    @arm      = create(:arm, protocol: protocol, subject_count: 10)
    @vg       = @arm.visit_groups.first
    @liv      = @arm.line_items_visits.first
    visit     = create(:visit, line_items_visit: @liv, visit_group: @vg, research_billing_qty: 1)

    visit dashboard_sub_service_request_path(ssr)
    wait_for_javascript_to_finish

    find('#adminTabs .nav-link', text: /^#{I18n.t('dashboard.sub_service_requests.study_schedule.header')}$/).click
    wait_for_javascript_to_finish
  end

  context 'visit group' do
    it 'should update the visit group' do
      first('.visit-group a').click
      wait_for_javascript_to_finish

      fill_in 'visit_group_window_before', with: 5
      fill_in 'visit_group_day', with: 10
      fill_in 'visit_group_window_after', with: 5
      fill_in 'visit_group_name', with: 'Visit Me More Often'

      click_button I18n.t('actions.submit')
      wait_for_javascript_to_finish

      expect(@vg.reload.window_before).to eq(5)
      expect(@vg.day).to eq(10)
      expect(@vg.window_after).to eq(5)
      expect(page).to have_selector('.visit-group a', text: 'Visit Me More Often')
    end
  end

  context 'subject count' do
    it 'should update the subject count and header cost' do
      first('td.subject-count a').click
      wait_for_javascript_to_finish
      fill_in 'line_items_visit_subject_count', with: '5'
      click_button I18n.t('actions.submit')
      wait_for_javascript_to_finish

      expect(@liv.reload.subject_count).to eq(5)
      expect(page).to have_selector('td.subject-count a', text: 5)
      expect(page).to have_selector('#displayCost', text: '$6.00')
    end
  end

  context 'your cost' do
    before :each do
      first('td.displayed-cost a').click
      wait_for_javascript_to_finish
      fill_in 'line_item_displayed_cost', with: '100.00'
      click_button I18n.t('actions.submit')
      wait_for_javascript_to_finish
    end

    it 'updates your cost' do
      expect(page).to have_selector('td.displayed-cost a', text: '$100.00')
    end
  end

  context 'in the Template Tab' do
    context 'visit (checkbox)' do
      before :each do
        first('.visit-quantity').click
        wait_for_javascript_to_finish
      end

      it 'should update the checkbox and header cost' do
        expect(first('.visit-quantity')).to be_checked
        expect(page).to have_selector('#displayCost', text: '$21.00')
      end
    end

    context 'check row' do
      before :each do
        first('.check-row').click
        confirm_swal
        wait_for_javascript_to_finish
      end

      it 'should update the checkbox and header cost' do
        expect(first('.visit-quantity')).to be_checked
        expect(page).to have_selector('#displayCost', text: '$21.00')
      end
    end

     context 'check column' do
      before :each do
        first('.check-column').click
        confirm_swal
        wait_for_javascript_to_finish
      end

      it 'should update the checkbox and header cost' do
        expect(first('.visit-quantity')).to be_checked
        expect(page).to have_selector('#displayCost', text: '$21.00')
      end
    end
  end

  context 'in the Quantity/Billing Tab' do
    before :each do
      click_link I18n.t('calendars.tabs.billing')
      wait_for_javascript_to_finish
    end

    context 'r/t/%' do
      before :each do
        first('td.visit a').click
        wait_for_javascript_to_finish

        fill_in 'visit_research_billing_qty', with: 5
        fill_in 'visit_insurance_billing_qty', with: 5
        fill_in 'visit_effort_billing_qty', with: 5
        click_button I18n.t('actions.submit')
        wait_for_javascript_to_finish
      end

      it 'should update r, t, \%, and header cost' do
        expect(@arm.visits.first.research_billing_qty).to eq(5)
        expect(@arm.visits.first.insurance_billing_qty).to eq(5)
        expect(@arm.visits.first.effort_billing_qty).to eq(5)
        expect(page).to have_selector('#displayCost', text: '$61.00')
      end
    end
  end
end
