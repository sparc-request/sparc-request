# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.feature 'edit a service' do
  background do
    default_catalog_manager_setup
    Tag.create(name: "ctrc")
    Tag.create(name: "epic")
  end

  scenario "successfully add a ServiceLevelComponent", js: true do
    click_link('MUSC Research Data Request (CDW)')

  end

  scenario 'successfully update a service under a program', js: true do
    click_link('Human Subject Review')
    # Program Select should defalut to parent Program
    wait_for_javascript_to_finish
    expect(selected_option('#service_program')).to eq('Office of Biomedical Informatics')

    # Core Select should default to None
    expect(selected_option('#service_core')).to eq('None')

    fill_in 'service_abbreviation', with: 'TestService'
    fill_in 'service_description', with: 'Description'
    fill_in 'service_order', with: '1'
    check 'service_is_available'

    first("#save_button").click
    expect(page).to have_content( 'Human Subject Review saved successfully' )
  end

  scenario 'successfully update a service under a core', js: true do
    click_link('MUSC Research Data Request (CDW)')

    # Program Select should defalut to parent Program
    wait_for_javascript_to_finish
    expect(selected_option('#service_program')).to eq('Office of Biomedical Informatics')

    # Core Select should default to parent Core
    expect(selected_option('#service_core')).to eq('Clinical Data Warehouse')

    fill_in 'service_abbreviation', with: 'TestServiceTwo'
    fill_in 'service_description', with: 'DescriptionTwo'
    fill_in 'service_order', with: '2'
    check 'service_is_available'

    first("#save_button").click
    expect(page).to have_content( 'MUSC Research Data Request (CDW) saved successfully' )
  end

  context "adding and removing tags", js: true do
    before :each do
      @service = Service.find_by_name("Human Subject Review")
      click_link("Human Subject Review")
    end

    it "should list the tags" do
      expect(page).to have_css('#service_tag_list_ctrc')
    end

    it "should be able to check a tag box" do
      find('#service_tag_list_epic').click
      first('#save_button').click
      expect(page).to have_content("Human Subject Review saved successfully")
      expect(find('#service_tag_list_epic')).to be_checked
      expect(@service.tag_list).to eq(['epic'])
    end
  end

  context "viewing epic section", js: true do
    before :each do
      click_link("Human Subject Review")
    end

    it "should not display epic section by default" do
      expect(page).not_to have_css('#epic_fieldset')
    end

    it "should display epic section if tagged with epic" do
      find('#service_tag_list_epic').click
      first("#save_button").click
      wait_for_javascript_to_finish
      expect(page).to have_content("Human Subject Review saved successfully")
      click_link('Human Subject Review')
      wait_for_javascript_to_finish

      expect(find('#epic_fieldset')).to be_visible
      find('#epic_fieldset').click
      sleep 3
      expect(first('#epic_fieldset fieldset')).to be_visible
    end
  end
end

def selected_option(select_selector)
  value = find(select_selector).value
  find("option[value='#{value}']").text
end
