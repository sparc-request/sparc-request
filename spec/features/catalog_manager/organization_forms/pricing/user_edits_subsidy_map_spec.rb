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

RSpec.describe 'User edits organization subsidy map', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution = create(:institution)
    @provider = create(:provider, :with_subsidy_map, parent_id: @institution.id)
    @subsidy_map = @provider.subsidy_map
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
  end

  context 'on a Provider' do
    context 'and the user edits the organization subsidy map' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish
        click_link 'Pricing'
        wait_for_javascript_to_finish
        find("#edit_subsidy_map_button").click
        wait_for_javascript_to_finish
      end

      it 'should edit the max percentage' do
        fill_in 'subsidy_map_max_percentage', with: "100"
        click_button 'Save'
        wait_for_javascript_to_finish

        @subsidy_map.reload
        expect(@subsidy_map.max_percentage).to eq(100)
      end

      it 'should edit the default percentage' do
        fill_in 'subsidy_map_default_percentage', with: "75"
        click_button 'Save'
        wait_for_javascript_to_finish

        @subsidy_map.reload
        expect(@subsidy_map.default_percentage).to eq(75)
      end
      it 'should edit the max dollar cap' do
        fill_in 'subsidy_map_max_dollar_cap', with: "150"
        click_button 'Save'
        wait_for_javascript_to_finish

        @subsidy_map.reload
        expect(@subsidy_map.max_dollar_cap).to eq(150)
      end

      it 'should edit the excluded funding sources' do
        bootstrap_select('#subsidy_map_excluded_funding_sources', 'Federal')
        find('form.form-horizontal').click
        click_button 'Save'
        wait_for_javascript_to_finish

        @subsidy_map.reload
        expect(@subsidy_map.excluded_funding_sources.size).to eq(1)
        expect(@subsidy_map.excluded_funding_sources.first.funding_source).to eq('federal')
      end

      it 'should edit the instructions' do
        fill_in 'subsidy_map_instructions', with: "Use the subsidy!"
        click_button 'Save'
        wait_for_javascript_to_finish

        @subsidy_map.reload
        expect(@subsidy_map.instructions).to eq("Use the subsidy!")
      end
    end
  end
end
