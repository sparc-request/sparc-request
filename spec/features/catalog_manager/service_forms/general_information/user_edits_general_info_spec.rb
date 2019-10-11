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

RSpec.describe 'User edits Service General Info', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution = create(:institution)
    @provider    = create(:provider, parent_id: @institution.id)
    @program     = create(:program, parent_id: @provider.id)
    @service     = create(:service, organization: @program)
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
    create(:tag, name: "epic")
  end

  context 'on a Service' do
    context 'and the user edits the service general info' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id} .glyphicon").click
        find("#provider-#{@provider.id} .glyphicon").click
        find("#program-#{@program.id} .glyphicon").click
        wait_for_javascript_to_finish
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
      end

      it 'should edit the program' do
        @program1 = create(:program, parent_id: @provider.id)
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish

        bootstrap3_select('#service_program', @program1.name)
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.program).to eq(@program1)
      end

      it 'should edit the core' do
        @core = create(:core, parent_id: @program.id)
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish

        bootstrap3_select('#service_core', @core.name)
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.core).to eq(@core)
      end

      it 'should edit the name' do
        fill_in 'service_name', with: "Daffodil"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.name).to eq("Daffodil")
      end

      it 'should edit the abbreviation' do
        fill_in 'service_abbreviation', with: "Tulip"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.abbreviation).to eq("Tulip")
      end

      it 'should edit the description' do
        fill_in 'service_description', with: "Orchids"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.description).to eq("Orchids")
      end

      it 'should edit the order' do
        fill_in 'service_order', with: "1"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.order).to eq(1)
      end

      it 'should select a tag' do
        bootstrap3_select('#service_tag_list', 'Epic')
        find('form.form-horizontal').click
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.tag_list.include?("epic")).to eq(true)
      end

      it 'should toggle Clinical/Non-clinical services if there is no pricing map' do
        first('#general-info div.toggle.btn').click
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.one_time_fee).to eq(true)
      end

      it 'should disable Clinical/Non-clinical services if there is a pricing map' do
        ##Create Pricing Map for this specific spec, and reload the service form
        create(:pricing_map, service_id: @service.id, display_date: Date.today, effective_date: Date.today)
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
        ##

        expect(page).to have_selector('[name="service[one_time_fee]"] + .toggle[disabled=disabled]')
      end

      it 'should disable Clinical/Non-clinical services if the service has line items' do
        ##Create calendar data for this specific spec, and reload the service form
        @sr = create(:service_request, :without_validations)
        @ssr = create(:sub_service_request, :without_validations, :with_organization, service_request: @sr)
        create(:line_item_without_validations, service_request_id: @sr.id, service_id:  @service.id, sub_service_request_id: @ssr.id)
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
        ##

        expect(page).to have_selector('[name="service[one_time_fee]"] + .toggle[disabled=disabled]')
      end

      it 'should toggle Display in Sparc' do
        ##Create Pricing Map for the specific spec, and reload the service form
        create(:pricing_map, service_id: @service.id, display_date: Date.today, effective_date: Date.today)
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish
        ##

        page.all('#general-info div.toggle.btn')[1].click
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.is_available).to eq(false)
      end

      it 'should disable Display in Sparc if there is no pricing map' do
        expect(page).to have_selector('[name="service[is_available]"] + .toggle[disabled=disabled]')
      end
    end
  end
end
