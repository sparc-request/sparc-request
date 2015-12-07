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

RSpec.feature 'User creates a new project', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    service_request.update_attribute(:status, 'first_draft')
    service_request.reload
    visit protocol_service_request_path service_request.id
    wait_for_javascript_to_finish
  end

  context 'and submits a blank protocol form' do
    scenario 'and sees some errors' do
      given_im_viewing_a_new_project
      when_i_submit_the_form
      then_i_should_see_some_errors_of_type 'protocol form'
    end
  end

  context 'and fills in the protocol form and submits it' do
    scenario 'and sees the authorized users page' do
      given_im_viewing_a_new_project
      when_i_fill_in_the_required_fields
      when_i_submit_the_form
      then_i_should_see_the_authorized_users_page
    end

    context 'and tries to add an authorized user without picking a role' do
      scenario 'and sees an error' do
        given_i_am_viewing_the_authorized_user_page
        when_i_press_add_authorized_user
        then_i_should_see_an_error_of_type 'missing role'
      end
    end

    context 'and tries to submit the form without adding a primary pi'

    context 'and adds an authorized user not yet on the protocol' do
      scenario 'and sees the user was added correctly' do
        given_i_am_viewing_the_authorized_user_page
        when_i_add_jug2_as_an_authorized_user
        then_i_should_see_jug2_in_the_authorized_users_list
      end
    end

    context 'and adds an authorized user already on the protocol' do
      scenario 'and sees an error' do
        given_i_am_viewing_the_authorized_user_page
      end
    end
  end
      select "Primary PI", from: "project_role_role"
      click_button "Add Authorized User"

      fill_autocomplete('user_search_term', with: 'bjk7');

      page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()

      select "Billing/Business Manager", from: "project_role_role"
      click_button "Add Authorized User"

      find('.continue_button').click

      expect(page).to have_css('.edit_project_id')
      expect(find(".edit_project_id")).to have_value Protocol.last.id.to_s
    end
  end
end

RSpec.describe "editing a project" do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request()
  build_project()

  before :each do
    visit protocol_service_request_path service_request.id
  end

  describe "editing the short title", js: true do

    it "should save the short title" do
      find('.edit-project').click
      fill_in "project_short_title", with: "Patsy"
      find('.continue_button').click
      wait_for_javascript_to_finish
      find('.continue_button').click
      wait_for_javascript_to_finish
      find('.edit-project').click

      expect(find("#project_short_title")).to have_value("Patsy")
    end
  end

  def given_im_viewing_a_new_project
    find('#protocol_Project').click
    wait_for_javascript_to_finish
    
    find('.new-project').click
    wait_for_javascript_to_finish
  end

  def given_i_am_viewing_the_authorized_user_page
    given_im_viewing_a_new_project
    when_i_fill_in_the_required_fields
    when_i_submit_the_form
  end

  def when_i_fill_in_the_required_fields
    fill_in "project_short_title", with: "Bob"
    fill_in "project_title", with: "Dole"
    select "Funded", from: "project_funding_status"
    select "Federal", from: "project_funding_source"
  end

  def when_i_submit_the_form
    find('.continue_button').click
  end

  def when_i_press_add_authorized_user
    click_button "Add Authorized User"
  end

  def when_i_add_jug2_as_an_authorized_user
    #Page defaults the current user in the form
    select "Primary PI", from: "project_role_role"
    click_button "Add Authorized User"
  end

  def then_i_should_see_the_authorized_users_page
    expect(page).to have_css('#project_role_role')
  end

  def then_i_should_see_jug2_in_the_authorized_users_list
    expect(page).to have_content('td', text: 'Julia Glenn')
  end

  def then_i_should_see_some_errors_of_type error_type
    case error_type
      when 'protocol form'
        expect(page).to have_content("Short title can't be blank")
        expect(page).to have_content("Title can't be blank")
        expect(page).to have_content("Funding status can't be blank")
      when 'missing role'
        expect(page).to have_text("Role can't be blank")
    end
  end
end
