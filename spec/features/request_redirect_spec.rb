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

RSpec.describe "Request redirect", js: true do
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

  describe 'adding service to a new request' do

    before :each do
      visit root_path
      wait_for_javascript_to_finish
      click_link("South Carolina Clinical and Translational Institute (SCTR)")
      wait_for_javascript_to_finish
      click_link('Office of Biomedical Informatics')
      wait_for_javascript_to_finish
    end

    it 'should display the redirect dialog' do
      find("#service-#{service.id}").click
      wait_for_javascript_to_finish
      expect(page).to have_content("New Request?")
    end

    it "should allow the user to add more services if 'yes' is clicked" do
      find("#service-#{service.id}").click
      wait_for_javascript_to_finish

      find("button.ui-button .ui-button-text", text: "Yes").click
      wait_for_javascript_to_finish

      find("#service-#{service2.id}").click
      wait_for_javascript_to_finish
      within('.cart-view') do
        expect(page).to have_content('Breast Milk Collection')
      end
    end

    it "should redirect to user portal if 'no' is clicked" do
      find("#service-#{service.id}").click
      wait_for_javascript_to_finish

      find("button.ui-button .ui-button-text", text: "No").click
      wait_for_javascript_to_finish

      expect(current_path).to eq(dashboard_root_path)
    end
  end
end
