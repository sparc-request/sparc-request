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

RSpec.describe 'User edits Organization Pricing', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution     = create(:institution)
    @provider        = create(:provider, :with_subsidy_map, parent_id: @institution.id)
    @catalog_manager = create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id, edit_historic_data: true)
    create(:pricing_setup, organization: @provider, display_date: Date.today - 1, effective_date: Date.today - 1, federal: 100, corporate: 100, other: 100, member: 100)
  end

  context 'on a Provider' do
    context 'and the user edits the pricing setup percent of fee' do
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

      it 'should edit the federal percent' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_federal', with: "50.00"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.pricing_setups.first.federal.to_i).to eq(50)
      end

      it 'should edit the corporate percent' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_corporate', with: "150.00"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.pricing_setups.first.corporate.to_i).to eq(150)
      end

      it 'should edit other percent' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_other', with: "150.00"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.pricing_setups.first.other.to_i).to eq(150)
      end

      it 'should edit the member percent' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_member', with: "150.00"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.pricing_setups.first.member.to_i).to eq(150)
      end

      it 'should edit corporate, other and member rates in the form if the Apply Federal % to All button is clicked' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_federal', with: "50.00"
        find("#apply_federal_percent").click
        wait_for_javascript_to_finish

        expect(find('#pricing_setup_corporate')[:value]).to eq("50.00")
        expect(find('#pricing_setup_other')[:value]).to eq("50.00")
        expect(find('#pricing_setup_member')[:value]).to eq("50.00")
      end

      it 'should save corporate, other and member rates in the datebase if the Apply Federal % to All button is clicked' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_federal', with: "50.00"
        find("#apply_federal_percent").click
        wait_for_javascript_to_finish
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.pricing_setups.first.corporate.to_i).to eq(50)
        expect(@provider.pricing_setups.first.other.to_i).to eq(50)
        expect(@provider.pricing_setups.first.member.to_i).to eq(50)
      end

      it 'should throw error if federal rate is more than corporate, other and member rates' do
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        fill_in 'pricing_setup_federal', with: "150.00"
        click_button 'Save'
        wait_for_javascript_to_finish

        expect(page).to have_content("Corporate must be greater than or equal to Federal Rate.")
        expect(page).to have_content("Other must be greater than or equal to Federal Rate.")
        expect(page).to have_content("Member must be greater than or equal to Federal Rate.")
      end

      it 'should disable federal, corporate, other and member rates if the catalog_manager cannot edit historic data' do
        @catalog_manager.update_attributes(edit_historic_data: false)
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        expect(find_by_id('pricing_setup_federal')).to be_disabled
        expect(find_by_id('pricing_setup_corporate')).to be_disabled
        expect(find_by_id('pricing_setup_other')).to be_disabled
        expect(find_by_id('pricing_setup_member')).to be_disabled
      end

      it 'should disable Apply Federal % to All button if the catalog_manager cannot edit historic data' do
        @catalog_manager.update_attributes(edit_historic_data: false)
        find(".edit_pricing_setup_link").click
        wait_for_javascript_to_finish

        expect(page).to have_no_selector('#apply_federal_percent')
      end

    end
  end

end
