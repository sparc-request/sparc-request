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

RSpec.describe 'User views a locked SSR', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization, use_default_statuses: false, process_ssrs: true)
                create(:pricing_setup, organization: org)
    pppv      = create(:service, organization: org, one_time_fee: false, pricing_map_count: 1)
    otf       = create(:service, organization: org, one_time_fee: true, pricing_map_count: 1)
    otf.pricing_maps.first.update_attributes(otf_unit_type: 'total')

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, protocol: protocol)
    ssr1      = create(:sub_service_request, service_request: @sr, organization: org)
    ssr2      = create(:sub_service_request, service_request: @sr, organization: org)
    li1       = create(:line_item, service_request: @sr, sub_service_request: ssr1, service: pppv)
    li2       = create(:line_item, service_request: @sr, sub_service_request: ssr2, service: otf, units_per_quantity: 5, quantity: 5)

    arm       = create(:arm, protocol: protocol, visit_count: 3, subject_count: 5)
    liv       = create(:line_items_visit, line_item: li1, arm: arm, subject_count: 5)
    vg        = create(:visit_group, arm: arm)
                create(:visit, visit_group: vg, line_items_visit: liv, research_billing_qty: 5, insurance_billing_qty: 5, effort_billing_qty: 5)

    org.editable_statuses.where(status: [ssr1.status, ssr2.status]).destroy_all

    visit service_calendar_service_request_path(srid: @sr.id)
    wait_for_javascript_to_finish
  end

  context 'with per patient per visit services' do
    context 'in the Template Tab' do
      scenario 'and sees the locked header' do
        expect(page).to have_selector('.pppv-calendar .organization-header.text-danger')
        expect(page).to have_selector('.pppv-calendar .glyphicon.glyphicon-lock.locked')
      end

      scenario 'and sees the locked service' do
        expect(page).to have_selector('.pppv-calendar .pppv-line-item-row.bg-danger.text-danger')
      end

      scenario 'and sees the non-editable subject count' do
        expect(page).to have_selector('.pppv-calendar td.subject-count', text: 5)
      end

      scenario 'and sees the locked row button' do
        expect(page.evaluate_script("$('.pppv-calendar .service-calendar-row').attr('disabled');")).to eq('disabled')
      end

      scenario 'and sees the locked visit checkboxes' do
        expect(page.evaluate_script("$('.pppv-calendar .visit-quantity').attr('disabled');")).to eq('disabled')
      end
    end

    context 'in the Quantity/Billing Tab' do
      before :each do
        click_link 'Quantity/Billing Tab'
        wait_for_javascript_to_finish
      end

      scenario 'and sees the locked header' do
        expect(page).to have_selector('.pppv-calendar .organization-header.text-danger')
        expect(page).to have_selector('.pppv-calendar .glyphicon.glyphicon-lock.locked')
      end

      scenario 'and sees the locked service' do
        expect(page).to have_selector('.pppv-calendar .pppv-line-item-row.bg-danger.text-danger')
      end

      scenario 'and sees the non-editable subject count' do
        expect(page).to have_selector('.pppv-calendar td.subject-count', text: 5)
      end

      scenario 'and sees the locked Research Billing Quantity' do
        expect(page).to have_selector('.pppv-calendar .research-billing-qty', text: 5)
      end

      scenario 'and sees the locked Insurance Billing Quantity' do
        expect(page).to have_selector('.pppv-calendar .insurance-billing-qty', text: 5)
      end

      scenario 'and sees the locked Effort Billing Quantity' do
        expect(page).to have_selector('.pppv-calendar .effort-billing-qty', text: 5)
      end
    end

    context 'in the Consolidated Request Tab' do
      scenario 'and sees the locked header' do
        expect(page).to have_selector('.pppv-calendar .organization-header.text-danger')
        expect(page).to have_selector('.pppv-calendar .glyphicon.glyphicon-lock.locked')
      end

      scenario 'and sees the locked service' do
        expect(page).to have_selector('.pppv-calendar .pppv-line-item-row.bg-danger.text-danger')
      end
    end
  end

  context 'with one time fee services' do
    scenario 'and sees the locked header' do
      expect(page).to have_selector('.otf-calendar .organization-header.text-danger')
      expect(page).to have_selector('.otf-calendar .glyphicon.glyphicon-lock.locked')
    end

    scenario 'and sees the locked service' do
      expect(page).to have_selector('.otf-calendar .otf-line-item-row.bg-danger.text-danger')
    end

    scenario 'and sees the non-editable Unit Type #' do
      expect(page).to have_selector('.otf-calendar .units-per-qty', text: 5)
    end

    scenario 'and sees the non-editable Qty Type #' do
      expect(page).to have_selector('.otf-calendar .qty', text: 5)
    end
  end
end
