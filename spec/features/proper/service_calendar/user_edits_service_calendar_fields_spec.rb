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
    org       = create(:organization)
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

    visit service_calendar_service_request_path(srid: sr.id)
    wait_for_javascript_to_finish
  end

  context 'in the Template Tab' do
    context 'to a valid value' do
      scenario 'window before' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_before', with: 5
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.window_before).to eq(5)
      end

      scenario 'window after' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_after', with: 5
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.window_after).to eq(5)
      end

      scenario 'day' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_day', with: 5
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.day).to eq(5)
      end

      scenario 'visit name' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_name', with: 'Visit Me'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.name).to eq('Visit Me')
      end

      scenario 'subject count' do
        find('.edit-subject-count.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@liv.reload.subject_count).to eq(5)
      end

      scenario 'unit type #' do
        find('.edit-units-per-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@otf_li.reload.units_per_quantity).to eq(5)
      end

      scenario 'qty type #' do
        find('.edit-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@otf_li.reload.quantity).to eq(5)
      end
    end

    context 'to an invalid value' do
      scenario 'window before' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_before', with: 'a lot'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(page).to have_content('Window before is not a number')
      end

      scenario 'window after' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_after', with: 'a lot'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(page).to have_content('Window after is not a number')
      end

      scenario 'day' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_day', with: 'someday'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(page).to have_content('Day is not a number')
      end

      scenario 'subject count' do
        find('.edit-subject-count.editable').click
        find('.editable-input input').set('a number')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Subject Count is not a number')
      end

      scenario 'unit type #' do
        find('.edit-units-per-qty.editable').click
        find('.editable-input input').set('a couple')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Units Per Quantity is not a number')
      end

      scenario 'qty type #' do
        find('.edit-qty.editable').click
        find('.editable-input input').set('none')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Quantity is not a number')
      end
    end
  end

  context 'in the Quantity/Billing Tab' do
    before :each do
      find('#billing-strategy-tab').click
      wait_for_javascript_to_finish
    end

    context 'to a valid value' do
      scenario 'window before' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_before', with: 5
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.window_before).to eq(5)
      end

      scenario 'window after' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_after', with: 5
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.window_after).to eq(5)
      end

      scenario 'day' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_day', with: 5
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.day).to eq(5)
      end

      scenario 'visit name' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_name', with: 'Visit Me'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(@vg.reload.name).to eq('Visit Me')
      end

      scenario 'subject count' do
        find('.edit-subject-count.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@liv.reload.subject_count).to eq(5)
      end

      scenario 'r' do
        find('a.edit-billing-qty', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_research_billing_qty', with: 5
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(@arm.visits.first.research_billing_qty).to eq(5)
      end

      scenario 't' do
        find('a.edit-billing-qty', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_insurance_billing_qty', with: 5
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(@arm.visits.first.insurance_billing_qty).to eq(5)
      end

      scenario '%' do
        find('a.edit-billing-qty', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_effort_billing_qty', with: 5
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(@arm.visits.first.effort_billing_qty).to eq(5)
      end

      scenario 'unit type #' do
        find('.edit-units-per-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@otf_li.reload.units_per_quantity).to eq(5)
      end

      scenario 'qty type #' do
        find('.edit-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@otf_li.reload.quantity).to eq(5)
      end
    end

    context 'to an invalid value' do
      scenario 'window before' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_before', with: 'a lot'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(page).to have_content('Window before is not a number')
      end

      scenario 'window after' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_window_after', with: 'a lot'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(page).to have_content('Window after is not a number')
      end

      scenario 'day' do
        find('a.edit-visit-group', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_group_day', with: 'a lot'
        click_button 'Save changes'
        wait_for_javascript_to_finish

        expect(page).to have_content('Day is not a number')
      end

      scenario 'subject count' do
        find('.edit-subject-count.editable').click
        find('.editable-input input').set('a number')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Subject Count is not a number')
      end

      scenario 'r' do
        find('a.edit-billing-qty', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_research_billing_qty', with: 'string'
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(page).to have_content("Research Billing Quantity is not a number")
      end

      scenario 't' do
        find('a.edit-billing-qty', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_insurance_billing_qty', with: 'string'
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(page).to have_content("Insurance Billing Quantity is not a number")
      end

      scenario '%' do
        find('a.edit-billing-qty', match: :first).click
        wait_for_javascript_to_finish

        fill_in 'visit_effort_billing_qty', with: 'string'
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(page).to have_content("Effort Billing Quantity is not a number")
      end

      scenario 'unit type #' do
        find('.edit-units-per-qty.editable').click
        find('.editable-input input').set('a couple')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Units Per Quantity is not a number')
      end

      scenario 'qty type #' do
        find('.edit-qty.editable').click
        find('.editable-input input').set('none')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Quantity is not a number')
      end
    end
  end
end
