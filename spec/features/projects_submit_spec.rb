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

RSpec.describe "creating a new project ", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test

  let!(:institution)  { create(:institution, name: 'Medical University of South Carolina', order: 1, abbreviation: 'MUSC', is_available: 1) }
  let!(:provider)     { create(:provider, name: 'South Carolina Clinical and Translational Institute (SCTR)', order: 1,
                               css_class: 'blue-provider', parent_id: institution.id, abbreviation: 'SCTR1', process_ssrs: 1, is_available: 1) }
  let!(:program)      { create(:program_with_pricing_setup, name: 'Office of Biomedical Informatics', order: 1, parent_id: provider.id,
                               abbreviation:'Informatics') }
  let!(:core)         { create(:core, type: 'Core', name: 'Clinical Data Warehouse', order: 1, parent_id: program.id,
                               abbreviation: 'Clinical Data Warehouse') }
  let!(:service)      { create(:service, name: 'MUSC Research Data Request (CDW)', abbreviation: 'CDW', order: 1, cpt_code: '',
                               organization_id: core.id, one_time_fee: true) }
  let!(:service2)     { create(:service, name: 'Breast Milk Collection', abbreviation: 'Breast Milk Collection', order: 1, cpt_code: '',
                               organization_id: core.id) }
  let!(:pricing_map)  { create(:pricing_map, service_id: service.id, unit_type: 'Per Query', unit_factor: 1, full_rate: 0,
                               exclude_from_indirect_cost: 0, unit_minimum: 1) }
  let!(:pricing_map2) { create(:pricing_map, service_id: service2.id, unit_type: 'Per patient/visit', unit_factor: 1, full_rate: 636,
                               exclude_from_indirect_cost: 0, unit_minimum: 1) }
  before :each do
    visit '/'
    click_link 'South Carolina Clinical and Translational Institute (SCTR)'
    wait_for_javascript_to_finish
    click_link 'Office of Biomedical Informatics'
    wait_for_javascript_to_finish
    click_button 'Add', match: :first
    wait_for_javascript_to_finish
    click_button 'Yes'
    wait_for_javascript_to_finish
    find('.submit-request-button').click
    click_link 'New Project'
    wait_for_javascript_to_finish
  end

  describe "submitting a blank form" do
    it "should show errors when submitting a blank form" do
      find('.continue_button').click
      expect(page).to have_content("Short title can't be blank")
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Funding status can't be blank")
    end
  end

  describe "submitting a filled form" do
    it "should clear errors and submit the form" do
      fill_in "project_short_title", with: "Bob"
      fill_in "project_title", with: "Dole"
      select "Funded", from: "project_funding_status"
      select "Federal", from: "project_funding_source"
      find('.continue_button').click
      expect(page).to have_css('#project_role_role')
      select "Primary PI", from: "project_role_role"
      click_button "Add Authorized User"
      fill_autocomplete('user_search_term', with: 'bjk7')
      page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
      select "Billing/Business Manager", from: "project_role_role"
      click_button "Add Authorized User"
      find('.continue_button').click
      wait_for_javascript_to_finish
      expect(page).to have_link 'Edit Project'
      click_link 'Edit Project'
      expect(find("#project_short_title")).to have_value("Bob")
    end
  end
end
