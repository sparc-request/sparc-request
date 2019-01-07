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

RSpec.describe 'User edits organization general info', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution = create(:institution)
    @provider = create(:provider, :with_subsidy_map, parent_id: @institution.id, process_ssrs: true)
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
    create(:tag, name: "clinical work fulfillment")
  end

  context 'on a Provider' do
    context 'and the user edits the organization general info' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish
      end

      it 'should edit the name' do
        fill_in 'organization_name', with: "Inigo Montoya"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.name).to eq("Inigo Montoya")
      end

      it 'should edit the abbreviation' do
        fill_in 'organization_abbreviation', with: "Mandy Patinkin"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.abbreviation).to eq("Mandy Patinkin")
      end

      it 'should edit the description' do
        fill_in 'organization_description', with: "Swordsman/Actor"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.description).to eq("Swordsman/Actor")
      end

      it 'should edit the acceptance language' do
        fill_in 'organization_ack_language', with: "You Killed My Father, Prepare To Die"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.ack_language).to eq("You Killed My Father, Prepare To Die")
      end

      it 'should edit the order' do
        fill_in 'organization_order', with: "2"
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.order).to eq(2)
      end

      it 'should toggle split/notify' do
        find('.split_notify_container div.toggle.btn').click
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.process_ssrs).to eq(false)
      end

      it 'should select a color' do
        bootstrap_select('#organization_css_class', 'blue')
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.css_class).to eq("blue-provider")
      end

      it 'should toggle display in sparc' do
        find('#display-in-sparc div.toggle.btn').click
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.is_available).to eq(false)
      end

      it 'should select a tag' do
        bootstrap_multiselect('#organization_tag_list', ['Fulfillment'])
        click_button 'Save'
        wait_for_javascript_to_finish

        @provider.reload
        expect(@provider.tag_list.include?("clinical work fulfillment")).to eq(true)
      end

    end
  end

end
