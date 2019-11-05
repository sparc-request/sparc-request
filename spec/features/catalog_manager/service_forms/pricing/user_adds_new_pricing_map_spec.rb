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

RSpec.describe 'User adds Service Pricing Map', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution     = create(:institution)
    @provider        = create(:provider, parent_id: @institution.id)
    @program         = create(:program, parent_id: @provider.id)
    @service         = create(:service, organization: @program, one_time_fee: false)
    @catalog_manager = create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id,  edit_historic_data: true)
  end

  context 'on a Service' do
    context 'and the user creates a new pricing map' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id} .glyphicon").click
        find("#provider-#{@provider.id} .glyphicon").click
        find("#program-#{@program.id} .glyphicon").click
        wait_for_javascript_to_finish
      end

      it 'should create a new pricing map for clinical service' do
        create(:pricing_setup, organization: @program)

        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
        click_link 'Pricing'
        wait_for_javascript_to_finish

        find("#new_pricing_map_link").click
        wait_for_javascript_to_finish

        bootstrap3_datepicker('#pricing_map_display_date')
        bootstrap3_datepicker('#pricing_map_effective_date')

        fill_in 'pricing_map_full_rate', with: "150.00"
        find('#pricing_map_federal_rate').click
        wait_for_javascript_to_finish

        fill_in 'pricing_map_federal_rate', with: "250.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_corporate_rate', with: "350.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_other_rate', with: "450.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_member_rate', with: "550.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_unit_type', with: "each"
        fill_in 'pricing_map_unit_factor', with: "1.00"
        fill_in 'pricing_map_unit_minimum', with: "1"

        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.pricing_maps.count).to eq(1)
      end

      it 'should create a new pricing map for non clinical service' do
        create(:pricing_setup, organization: @program)
        @service.update_attributes(one_time_fee: true)

        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
        click_link 'Pricing'
        wait_for_javascript_to_finish


        find("#new_pricing_map_link").click
        wait_for_javascript_to_finish

        bootstrap3_datepicker('#pricing_map_display_date')
        bootstrap3_datepicker('#pricing_map_effective_date')

        fill_in 'pricing_map_full_rate', with: "150.00"
        find('#pricing_map_federal_rate').click
        wait_for_javascript_to_finish

        fill_in 'pricing_map_federal_rate', with: "250.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_corporate_rate', with: "350.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_other_rate', with: "450.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_member_rate', with: "550.00"
        find('.modal-body').click
        accept_confirm
        wait_for_javascript_to_finish

        fill_in 'pricing_map_otf_unit_type', with: "days"
        fill_in 'pricing_map_quantity_type', with: "hours"
        fill_in 'pricing_map_quantity_minimum', with: "1"
        fill_in 'pricing_map_unit_factor', with: "1.00"
        fill_in 'pricing_map_units_per_qty_max', with: "1"

        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.pricing_maps.count).to eq(1)
      end

      it 'should disable Add Pricing Map button if there is no pricing setup' do
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
        click_link 'Pricing'
        wait_for_javascript_to_finish

        expect(page).to have_selector('#new_pricing_map_link.disabled')
        expect(page).to have_content('There must be a pricing setup defined in order to add a pricing map.')
      end
    end
  end
end
