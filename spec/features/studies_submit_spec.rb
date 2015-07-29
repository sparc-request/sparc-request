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

RSpec.describe "creating a new study ", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study()

  before :each do
    visit protocol_service_request_path service_request.id
    expect(page).to have_css('.new-study')
    click_link "New Study"
  end

  describe "submitting a blank form" do

    it "should show errors when submitting a blank form" do
      find('.continue_button').click
      expect(page).to have_content("Short title can't be blank")
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Funding status can't be blank")
      expect(page).to have_content("Sponsor name can't be blank")
    end
  end

  describe "submitting a filled form" do

    it "should clear errors and submit the form" do
      fill_in "study_short_title", with: "Bob"
      fill_in "study_title", with: "Dole"
      choose('study_has_cofc_true')
      fill_in "study_sponsor_name", with: "Captain Kurt 'Hotdog' Zanzibar"
      select "Funded", from: "study_funding_status"
      select "Federal", from: "study_funding_source"

      find('.continue_button').click

      select "Primary PI", from: "project_role_role"
      click_button "Add Authorized User"
      sleep 1

      fill_autocomplete('user_search_term', with: 'bjk7')
      save_and_open_screenshot
      page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
      select "Billing/Business Manager", from: "project_role_role"
      click_button "Add Authorized User"

      find('.continue_button').click

      expect(find(".edit_study_id")).to have_value Protocol.last.id.to_s
    end
  end
end

RSpec.describe "editing a study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request()
  build_study()

  before :each do
    visit protocol_service_request_path service_request.id
    find('.edit-study').click
  end

  describe "editing the short title" do

    it "should save the short title" do
      select "Funded", from: "study_funding_status"
      select "Federal", from: "study_funding_source"
      fill_in "study_short_title", with: "Bob"
      find('.continue_button').click
      wait_for_javascript_to_finish
      find('.continue_button').click
      wait_for_javascript_to_finish
      find('.edit-study').click

      expect(find("#study_short_title")).to have_value("Bob")
    end
  end

  describe "setting epic access" do

    it 'should default to no for non primary pis' do
      find('.continue_button').click
      expect(find("#study_project_roles_attributes_#{jpl6.id}_epic_access_false")).to be_checked
    end

  end
end
