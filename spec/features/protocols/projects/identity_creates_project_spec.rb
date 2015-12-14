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

RSpec.feature 'User wants to create a Project', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    service_request.update_attribute(:status, 'first_draft')
  end

  #TODO: Add Authorized Users Specs
  context 'and clicks the New Project button' do
    scenario 'and sees the Protocol Information form' do
      given_i_am_viewing_the_service_request_protocol_page
      when_i_select_the_project_radio
      when_i_click_the_new_project_button
      then_i_should_see_the_protocol_information_page
    end

    scenario 'and sees the cancel button' do
      given_i_am_viewing_the_service_request_protocol_page
      when_i_select_the_project_radio
      when_i_click_the_new_project_button
      then_i_should_see_the_nav_button_with_text 'Cancel'
    end
    
    scenario 'and sees the continue button' do
      given_i_am_viewing_the_service_request_protocol_page
      when_i_select_the_project_radio
      when_i_click_the_new_project_button
      then_i_should_see_the_nav_button_with_text 'Continue'
    end

    context 'and submits the form without filling out required fields' do
      scenario 'and sees some errors' do
        given_i_am_viewing_the_protocol_information_page
        when_i_submit_the_form
        then_i_should_see_errors_of_type 'protocol information required fields'
      end
    end

    context 'and submits the form without selecting a funding source' do
      scenario 'and sees some errors' do
        given_i_am_viewing_the_protocol_information_page
        when_i_select_the_funding_status
        when_i_submit_the_form
        then_i_should_see_errors_of_type 'protocol information funding source'
      end
    end

    context 'and submits the form without selecting a potential funding source' do
      scenario 'and sees some errors' do
        given_i_am_viewing_the_protocol_information_page
        when_i_select_the_funding_status "Pending Funding"
        when_i_submit_the_form
        then_i_should_see_errors_of_type 'protocol information potential funding source'
      end
    end

    context 'and submits the form after filling out required fields' do
      scenario 'and sees the Authorized Users page' do
        given_i_am_viewing_the_protocol_information_page
        when_i_fill_out_the_protocol_information
        when_i_submit_the_form
        then_i_should_see_the_authorized_users_page
      end

      scenario 'and sees the go back button' do
        given_i_am_viewing_the_protocol_information_page
        when_i_fill_out_the_protocol_information
        when_i_submit_the_form
        then_i_should_see_the_nav_button_with_text 'Go Back' 
      end

      scenario 'and sees the save and continue button' do
        given_i_am_viewing_the_protocol_information_page
        when_i_fill_out_the_protocol_information
        when_i_submit_the_form
        then_i_should_see_the_nav_button_with_text 'Save & Continue' 
      end

      context 'TEMP: and adds themself as a Primary PI and submits the Project' do
        scenario 'and sees the Project with correct information' do
          given_i_am_viewing_the_authorized_users_page
          when_i_add_myself_as_a_primary_pi
          when_i_submit_the_form
          then_i_should_see_the_project_was_added_correctly
        end
      end
    end
  end

  def given_i_am_viewing_the_service_request_protocol_page
    visit protocol_service_request_path service_request.id
  end

  def given_i_am_viewing_the_protocol_information_page
    given_i_am_viewing_the_service_request_protocol_page
    when_i_select_the_project_radio
    when_i_click_the_new_project_button
  end

  def given_i_am_viewing_the_authorized_users_page
    given_i_am_viewing_the_protocol_information_page
    when_i_fill_out_the_protocol_information
    when_i_submit_the_form
  end

  def when_i_select_the_project_radio
    find("#protocol_Project").click
  end

  def when_i_click_the_new_project_button
    click_link "New Project"
  end

  def when_i_fill_out_the_short_title short_title="Fake Short Title"
    fill_in "project_short_title", with: short_title
  end

  def when_i_fill_out_the_title title="Fake Title"
    fill_in "project_title", with: title
  end

  def when_i_select_the_funding_status funding_status="Funded"
    select funding_status, from: "project_funding_status"
  end

  def when_i_select_the_funding_source funding_source="Federal"
    select funding_source, from: "project_funding_source"
  end

  def when_i_fill_out_the_protocol_information
    when_i_fill_out_the_short_title
    when_i_fill_out_the_title
    when_i_select_the_funding_status
    when_i_select_the_funding_source
  end

  def when_i_add_myself_as_a_primary_pi
    select "Primary PI", from: "project_role_role"
    find("button.add-authorized-user").click
    wait_for_javascript_to_finish
  end

  def when_i_submit_the_form
    find('.continue_button').click
    wait_for_javascript_to_finish
  end

  def then_i_should_see_the_protocol_information_page
    expect(page).to have_text("STEP 1: Protocol Information")
  end

  def then_i_should_see_the_authorized_users_page
    expect(page).to have_text("STEP 1: Add Users")
  end

  def then_i_should_see_the_project_was_added_correctly
    project = Protocol.last
    
    expect(project.type).to eq("Project")
    expect(project.short_title).to eq("Fake Short Title")
    expect(project.title).to eq("Fake Title")
    expect(project.funding_status).to eq("funded")
    expect(project.funding_source).to eq("federal")
  end

  def then_i_should_see_the_nav_button_with_text text
    case text
      when 'Cancel'
        expect(page).to have_selector("a.cancel span", text: text)
      when 'Go Back'
        expect(page).to have_selector("a.go-back span", text: text)
      when 'Continue'
        expect(page).to have_selector("a.continue span", text: text)
      when 'Save & Continue'
        expect(page).to have_selector("a.save span", text: text)
      else
        puts "An unexpected nav button text was found in then_i_should_see_the_nav_button_with_text. Perhaps there was a typo?"
    end
  end

  def then_i_should_see_errors_of_type error_type
    case error_type
      when 'protocol information required fields'
        expect(page).to have_content("Short title can't be blank")
        expect(page).to have_content("Title can't be blank")
        expect(page).to have_content("Funding status can't be blank")
      when 'protocol information funding source'
        expect(page).to have_content("Funding source You must select a funding source")
      when 'protocol information potential funding source'  
        expect(page).to have_content("Potential funding source You must select a potential funding source")
      else
        puts "An unexpected error was found in then_i_should_see_errors_of_type. Perhaps there was a typo?"
        expect(0).to eq(1)
    end
  end
end
