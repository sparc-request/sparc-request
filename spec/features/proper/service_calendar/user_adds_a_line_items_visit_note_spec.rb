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
# Line Item Visit notes are for PPPV
RSpec.describe 'User adds a line items visit note', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization)
    org2      = create(:organization)
                create(:pricing_setup, organization: org)
                create(:pricing_setup, organization: org2)
    service   = create(:service, organization: org, one_time_fee: false, cpt_code: "4015", pricing_map_count: 1)
    service2  = create(:service, organization: org2, one_time_fee: false, pricing_map_count: 1)

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, protocol: protocol)
    @ssr      = create(:sub_service_request, service_request: @sr, organization: org)
    @ssr2     = create(:sub_service_request, service_request: @sr, organization: org2)
    li        = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: service)
    li2       = create(:line_item, service_request: @sr, sub_service_request: @ssr2, service: service2)
    
    arm       = create(:arm, protocol: protocol)
    @liv      = arm.line_items_visits.first

    create(:visit, line_items_visit_id: @liv.id, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0)
  end

  context 'before clicking the notes button' do
    scenario 'sees black note badge with note count 0' do
      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      expect(page).not_to have_selector("#lineitemsvisit_#{@liv.id}_notes",class: 'blue-badge')
      expect(page).to have_selector("#lineitemsvisit_#{@liv.id}_notes", text: '0')
    end
  end

  context 'clicks notes button' do
    before :each do
      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      find("#lineitemsvisit_#{@liv.id}_notes").click
      wait_for_javascript_to_finish
    end

    scenario 'and sees notes modal' do
      expect(page).to have_css('#notes-modal')  
    end

    scenario 'and sees service name' do
      expect(page).to have_content("#{@liv.line_item.service.name} (#{@liv.line_item.service.cpt_code})")
    end
  end

  context 'clicks add note button' do
    before :each do
      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      find("#lineitemsvisit_#{@liv.id}_notes").click
      wait_for_javascript_to_finish

      click_link I18n.t(:notes)[:add]
      wait_for_javascript_to_finish
    end

    scenario 'and sees new notes modal' do
      expect(page).to have_css('#note-form-modal')  
    end

    scenario 'and sees service name' do
      expect(page).to have_content("#{@liv.line_item.service.name} (#{@liv.line_item.service.cpt_code})")
    end
  end

  context 'enters a note and clicks add' do
    before :each do
      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      find("#lineitemsvisit_#{@liv.id}_notes").click
      wait_for_javascript_to_finish

      click_link I18n.t(:notes)[:add]
      wait_for_javascript_to_finish

      fill_in 'note_body', with: 'test'
      click_button I18n.t(:actions)[:submit]
      wait_for_javascript_to_finish
    end

    scenario 'and sees note in modal table' do
      expect(page).to have_css('td.note', text: 'test')
    end

    scenario 'and closes the modal to see the blue note with updated note count' do
      click_button 'Close'
      expect(page).to have_selector("#lineitemsvisit_#{@liv.id}_notes", text: '1', visible: true, class: 'blue-badge')
    end
  end

  context 'clicks notes button on consolidated request tab' do
    before :each do
      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'Consolidated Request Tab'
      wait_for_javascript_to_finish

      find("#lineitemsvisit_#{@liv.id}_notes").click
      wait_for_javascript_to_finish
    end

    scenario 'and sees notes modal' do
      expect(page).to have_css('#notes-modal')  
    end

    scenario 'and sees service name' do
      expect(page).to have_content("#{@liv.line_item.service.name} (#{@liv.line_item.service.cpt_code})")
    end
  end

  context 'clicks notes button on quantity/billing tab' do
    before :each do
      visit service_calendar_service_request_path(srid: @sr.id)
      wait_for_javascript_to_finish

      click_link 'Quantity/Billing Tab'
      wait_for_javascript_to_finish
      
      find("#lineitemsvisit_#{@liv.id}_notes").click
      wait_for_javascript_to_finish
    end

    scenario 'and sees notes modal' do
      expect(page).to have_css('#notes-modal')  
    end

    scenario 'and sees service name' do
      expect(page).to have_content("#{@liv.line_item.service.name} (#{@liv.line_item.service.cpt_code})")
    end
  end
end
