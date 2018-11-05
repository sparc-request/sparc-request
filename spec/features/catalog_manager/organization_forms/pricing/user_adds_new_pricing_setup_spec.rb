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

RSpec.describe 'User adds Organization Pricing Setup', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution     = create(:institution)
    @provider        = create(:provider, :with_subsidy_map, parent_id: @institution.id)
    @catalog_manager = create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
  end

  context 'on a Provider' do
    context 'and the user creates a new pricing setup' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish
        click_link 'Pricing'
        wait_for_javascript_to_finish
      end

      it 'should create a new pricing setup' do
        find("#new_pricing_setup_link").click
        wait_for_javascript_to_finish

        find('#pricing_setup_display_date').click
        find('td.today').click

        find('#pricing_setup_effective_date').click
        find('td.today').click

        first('.modal-body div.toggle.btn').click

        fill_in 'pricing_setup_federal', with: "100.00"
        fill_in 'pricing_setup_corporate', with: "100.00"
        fill_in 'pricing_setup_other', with: "100.00"
        fill_in 'pricing_setup_member', with: "100.00"

        bootstrap_select('#pricing_setup_college_rate_type', 'Federal Rate')
        bootstrap_select('#pricing_setup_federal_rate_type', 'Federal Rate')
        bootstrap_select('#pricing_setup_industry_rate_type', 'Federal Rate')
        bootstrap_select('#pricing_setup_investigator_rate_type', 'Federal Rate')
        bootstrap_select('#pricing_setup_internal_rate_type', 'Federal Rate')
        bootstrap_select('#pricing_setup_foundation_rate_type', 'Federal Rate')
        bootstrap_select('#pricing_setup_unfunded_rate_type', 'Federal Rate')

        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.pricing_setups.count).to eq(1)
      end

    end
  end

end
