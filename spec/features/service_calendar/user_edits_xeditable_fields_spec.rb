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

RSpec.describe 'User sets each XEditable field', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization)
    pricing   = create(:pricing_setup, organization: org)
    pppv      = create(:service, organization: org, one_time_fee: false)
    otf       = create(:service, organization: org, one_time_fee: true)
    otf.pricing_maps.first.update_attributes(otf_unit_type: 'total', units_per_quantity: 1, quantity: 1)

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    sr        = create(:service_request_without_validations, protocol: protocol)
    ssr       = create(:sub_service_request, service_request: sr, organization: org)
    @pppv_li  = create(:line_item, service_request: sr, sub_service_request: ssr, service: pppv)
    @otf_li   = create(:line_item, service_request: sr, sub_service_request: ssr, service: otf, units_per_quantity: 1, quantity: 1)
    
    @arm      = create(:arm, protocol: protocol, subject_count: 10)
    vg        = create(:visit_group, arm: @arm, day: 1)
    @liv      = create(:line_items_visit, line_item: @pppv_li, arm: @arm, subject_count: 1)
                create(:visit, visit_group: vg, line_items_visit: @liv)

    stub_const('EDITABLE_STATUSES', { })

    visit service_calendar_service_request_path(sr)
    wait_for_javascript_to_finish
  end

  context 'in the Template Tab' do
    context 'to a valid value' do
      scenario 'window before' do
        find('.window-before.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.window_before).to eq(5)
      end

      scenario 'window after' do
        find('.window-after.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.window_after).to eq(5)
      end

      scenario 'day' do
        find('.day.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.day).to eq(5)
      end

      scenario 'visit name' do
        find('.visit-group-name.editable').click
        find('.editable-input input').set('Visit Me')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.name).to eq('Visit Me')
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
        find('.window-before.editable').click
        find('.editable-input input').set('a lot')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Window Before is not a number')
      end

      scenario 'window after' do
        find('.window-after.editable').click
        find('.editable-input input').set('not a lot')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Window After is not a number')
      end

      scenario 'day' do
        find('.day.editable').click
        find('.editable-input input').set('someday')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(page).to have_selector('.editable-error-block', visible: true)
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
        find('.window-before.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.window_before).to eq(5)
      end

      scenario 'window after' do
        find('.window-after.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.window_after).to eq(5)
      end

      scenario 'day' do
        find('.day.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.day).to eq(5)
      end

      scenario 'visit name' do
        find('.visit-group-name.editable').click
        find('.editable-input input').set('Visit Me')
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visit_groups.first.name).to eq('Visit Me')
      end

      scenario 'subject count' do
        find('.edit-subject-count.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@liv.reload.subject_count).to eq(5)
      end

      scenario 'r' do
        find('.edit-research-billing-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visits.first.research_billing_qty).to eq(5)
      end

      scenario 't' do
        find('.edit-insurance-billing-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
        wait_for_javascript_to_finish

        expect(@arm.visits.first.insurance_billing_qty).to eq(5)
      end

      scenario '%' do
        find('.edit-effort-billing-qty.editable').click
        find('.editable-input input').set(5)
        find('.editable-submit').click
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
        find('.window-before.editable').click
        find('.editable-input input').set('a lot')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Window Before is not a number')
      end

      scenario 'window after' do
        find('.window-after.editable').click
        find('.editable-input input').set('not a lot')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Window After is not a number')
      end

      scenario 'day' do
        find('.day.editable').click
        find('.editable-input input').set('someday')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
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
        find('.edit-research-billing-qty.editable').click
        find('.editable-input input').set('a number')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Research Billing Qty is not a number')
      end

      scenario 't' do
        find('.edit-insurance-billing-qty.editable').click
        find('.editable-input input').set('not a number')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Insurance Billing Qty is not a number')
      end

      scenario '%' do
        find('.edit-effort-billing-qty.editable').click
        find('.editable-input input').set('imaginary number')
        find('.editable-submit').click

        expect(page).to have_selector('.editable-error-block', visible: true)
        expect(page).to have_content('Effort Billing Qty is not a number')
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