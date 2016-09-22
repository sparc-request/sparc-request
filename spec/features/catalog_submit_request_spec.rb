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

RSpec.describe 'as a user on catalog page' do
  let_there_be_lane
  fake_login_for_each_test

  after :each do
    wait_for_javascript_to_finish
  end

  let!(:institution)  {create(:institution, id: 53, name: 'Medical University of South Carolina', order: 1,abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {create(:provider, id: 10, name: 'South Carolina Clinical and Translational Institute (SCTR)', order: 1, css_class: 'blue-provider', parent_id: institution.id, abbreviation: 'SCTR1', process_ssrs: 1, is_available: 1)}

  let!(:program) {create(:program_with_pricing_setup, name: 'Office of Biomedical Informatics', order: 1, parent_id: provider.id, abbreviation:'Informatics')}
  let!(:program2) {create(:program_with_pricing_setup, name:'Clinical and Translational Research Center (CTRC)', order: 2, parent_id: provider.id, abbreviation:'Informatics')}

  let!(:core) {create(:core, id: 33, type: 'Core', name: 'Clinical Data Warehouse', order: 1, parent_id: program.id, abbreviation: 'Clinical Data Warehouse')}
  let!(:core2) {create(:core, id: 8, type: 'Core', name: 'Nursing Services', abbreviation: 'Nursing Services', order: 1, parent_id: program2.id)}

  let!(:service) {create(:service, id: 67, name: 'MUSC Research Data Request (CDW)', abbreviation: 'CDW', order: 1, cpt_code: '', organization_id: core.id, one_time_fee: true)}
  let!(:service2) {create(:service, id: 16, name: 'Breast Milk Collection', abbreviation: 'Breast Milk Collection', order: 1, cpt_code: '', organization_id: core2.id)}

  let!(:pricing_map) {create(:pricing_map, service_id: 67, unit_type: 'Per Query', unit_factor: 1, full_rate: 0, exclude_from_indirect_cost: 0, unit_minimum: 1)}
  let!(:pricing_map2) {create(:pricing_map, service_id: 16, unit_type: 'Per patient/visit', unit_factor: 1, full_rate: 636, exclude_from_indirect_cost: 0, unit_minimum: 1)}

  it 'Submit Request', js: true do
    visit root_path

    click_link("South Carolina Clinical and Translational Institute (SCTR)")
    expect(find(".provider-name")).to have_text("South Carolina Clinical and Translational Institute (SCTR)")

    click_link('Office of Biomedical Informatics')
    click_button("Add")

    find("button.ui-button .ui-button-text", text: "Yes").click
    wait_for_javascript_to_finish
    
    click_link("Clinical and Translational Research Center (CTRC)")
    click_button("Add")
    find('.submit-request-button').click
  end

end
