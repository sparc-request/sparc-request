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

    click_link 'Clinical Services'
    wait_for_javascript_to_finish
  end

  context 'in the Template Tab' do

    before :each do
      click_link 'Template Tab'
      wait_for_javascript_to_finish
    end

    context 'to a valid value' do

      context 'visit (checkbox)' do
        before :each do
          @visit_quantity = find('.visit-quantity', match: :first)
          @visit_quantity.click
          wait_for_javascript_to_finish
        end

        it 'should check the checkbox' do
          expect( @visit_quantity).to be_checked
        end

        it 'should update header total cost' do
          expect(page).to have_css('.display_cost', text: '$21.00')
        end
      end

      context 'check row' do
        before :each do
          first('.service-calendar-row').click
          accept_confirm
          wait_for_javascript_to_finish
        end

        it 'should check the checkbox' do
          expect(find('.visit-quantity', match: :first)).to be_checked
        end

        it 'should update header total cost' do
          expect(page).to have_css('.display_cost', text: '$21.00')
        end
      end

       context 'check column' do
        before :each do
          first('.service-calendar-column').click
          accept_confirm
          wait_for_javascript_to_finish
        end

        it 'should check the checkbox' do
          expect(find('.visit-quantity', match: :first)).to be_checked
        end

        it 'should update header total cost' do
          expect(page).to have_css('.display_cost', text: '$21.00')
        end
      end

      context 'subject count' do
        before :each do
          find('.edit-subject-count.editable').click
          find('.editable-input input').set(5)
          find('.editable-submit').click
          wait_for_javascript_to_finish
        end

        it 'updates subject count' do
          expect(@liv.reload.subject_count).to eq(5)
        end

        it 'should update header total cost' do
          expect(page).to have_css('.display_cost', text: '$6.00')
        end
      end

      context 'your cost' do
        before :each do
          find('.edit-your-cost.editable', match: :first).click
          find('.editable-input input').set(100)
          find('.editable-submit').click
          wait_for_javascript_to_finish
        end

        it 'updates your cost' do
          expect(page).to have_css('.edit-your-cost', text: '$100.00')
        end
      end
    end

    context 'to an invalid value' do
      context 'subject count' do
        before :each do
          find('.edit-subject-count.editable').click
          find('.editable-input input').set('a number')
          find('.editable-submit').click
          wait_for_javascript_to_finish
        end

        it 'should throw error' do
          expect(page).to have_selector('.editable-error-block', visible: true)
          expect(page).to have_content('Subject Count is not a number')
        end

        it 'should not update header total' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end
    end
  end

  context 'in the Quantity/Billing Tab' do
    before :each do
      click_link 'Quantity/Billing Tab'
      wait_for_javascript_to_finish
    end

    context 'to a valid value' do
      context 'subject count' do
        before :each do
          find('.edit-subject-count.editable').click
          find('.editable-input input').set(5)
          find('.editable-submit').click
          wait_for_javascript_to_finish
        end

        it 'should update subject count' do
          expect(@liv.reload.subject_count).to eq(5)
        end

        it 'should update header total cost' do
          expect(page).to have_css('.display_cost', text: '$6.00')
        end
      end

      context 'r' do
        before :each do
          find('a.edit-billing-qty', match: :first).click
          wait_for_javascript_to_finish

          fill_in 'visit_research_billing_qty', with: 5
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        it 'should update r' do
          expect(@arm.visits.first.research_billing_qty).to eq(5)
        end

        it 'should update header total cost' do
         expect(page).to have_css('.display_cost', text: '$61.00')
        end
      end

      context 't' do
        before :each do
          find('a.edit-billing-qty', match: :first).click
          wait_for_javascript_to_finish

          fill_in 'visit_insurance_billing_qty', with: 5
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        it 'should update t' do
          expect(@arm.visits.first.insurance_billing_qty).to eq(5)
        end
        it 'should not update header total cost' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end

      context '%' do
        before :each do
          find('a.edit-billing-qty', match: :first).click
          wait_for_javascript_to_finish

          fill_in 'visit_effort_billing_qty', with: 5
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        it 'should update %' do
          expect(@arm.visits.first.effort_billing_qty).to eq(5)
        end

        it 'should not update header total cost' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end
    end

    context 'to an invalid value' do
      context 'subject count' do
        before :each do
          find('.edit-subject-count.editable').click
          find('.editable-input input').set('a number')
          find('.editable-submit').click
        end

        it 'should throw an error' do
          expect(page).to have_selector('.editable-error-block', visible: true)
          expect(page).to have_content('Subject Count is not a number')
        end

        it 'should not update header total cost' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end

      context 'r' do
        before :each do
          find('a.edit-billing-qty', match: :first).click
          wait_for_javascript_to_finish

          fill_in 'visit_research_billing_qty', with: 'string'
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        it 'should throw an error' do
          expect(page).to have_content("Research Billing Quantity is not a number")
        end

        it 'should not update header total cost' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end

      context 't' do
        before :each do
          find('a.edit-billing-qty', match: :first).click
          wait_for_javascript_to_finish

          fill_in 'visit_insurance_billing_qty', with: 'string'
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        it 'should throw an error' do
          expect(page).to have_content("Insurance Billing Quantity is not a number")
        end

        it 'should not update header total cost' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end

      context '%' do
        before :each do
          find('a.edit-billing-qty', match: :first).click
          wait_for_javascript_to_finish

          fill_in 'visit_effort_billing_qty', with: 'string'
          click_button 'Save'
          wait_for_javascript_to_finish
        end

        it 'should throw an error' do
          expect(page).to have_content("Effort Billing Quantity is not a number")
        end

        it 'should not update header total cost' do
          expect(page).to have_css('.display_cost', text: '$11.00')
        end
      end
    end
  end
end
