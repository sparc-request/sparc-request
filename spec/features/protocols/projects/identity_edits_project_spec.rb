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

RSpec.feature 'User wants to edit a Project', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    service_request.update_attribute(:status, 'first_draft')
  end

  context 'and clicks the Edit Project button' do
    scenario 'and sees the Protocol Information form' do
      given_i_am_viewing_the_service_request_protocol_page
      when_i_select_the_project_radio
      when_i_select_a_project
      when_i_click_the_edit_project_button
      then_i_should_see_the_protocol_information_page
    end

    scenario 'and sees the cancel button' do
      given_i_am_viewing_the_service_request_protocol_page
      when_i_select_the_project_radio
      when_i_select_a_project
      when_i_click_the_edit_project_button
      then_i_should_see_the_nav_button_with_text 'Cancel'
    end
    
    scenario 'and sees the continue button' do
      given_i_am_viewing_the_service_request_protocol_page
      when_i_select_the_project_radio
      when_i_select_a_project
      when_i_click_the_edit_project_button
      then_i_should_see_the_nav_button_with_text 'Continue'
    end

    context 'and clears the required fields and submits the form' do
      scenario 'and sees some errors' do
        given_i_am_viewing_the_protocol_information_page
        when_i_clear_the_required_fields
        when_i_submit_the_form
        then_i_should_see_errors_of_type 'protocol information required fields'
      end
    end

    context 'and clears the funding source and submits the form' do
      scenario 'and sees some errors' do
        given_i_am_viewing_the_protocol_information_page
        when_i_select_the_funding_source "Select a Funding Source"
        when_i_submit_the_form
        then_i_should_see_errors_of_type 'protocol information funding source'
      end
    end

    context 'and clears the potential funding source and submits the form' do
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
        when_i_submit_the_form
        then_i_should_see_the_authorized_users_page
      end

      scenario 'and sees the go back button' do
        given_i_am_viewing_the_protocol_information_page
        when_i_submit_the_form
        then_i_should_see_the_nav_button_with_text 'Go Back' 
      end

      scenario 'and sees the save and continue button' do
        given_i_am_viewing_the_protocol_information_page
        when_i_submit_the_form
        then_i_should_see_the_nav_button_with_text 'Save & Continue' 
      end
    end

    context 'and submits the project after modifying it' do
      scenario 'and sees the project has been updated' do
        given_i_am_viewing_the_protocol_information_page
        when_i_modify_the_project
        when_i_submit_the_form
        when_i_submit_the_form
        then_i_should_see_the_updated_project
      end
    end
  end

  def given_i_am_viewing_the_service_request_protocol_page
    visit protocol_service_request_path service_request.id
    wait_for_javascript_to_finish
  end

  def given_i_am_viewing_the_protocol_information_page
    given_i_am_viewing_the_service_request_protocol_page
    when_i_select_a_project
    when_i_click_the_edit_project_button
  end

  def when_i_select_the_project_radio
    find("input#protocol_Project").click
  end

  def when_i_select_a_project
    project = Protocol.first
    select "#{project.id} - #{project.short_title}", from: "service_request_protocol_id"
  end

  def when_i_click_the_edit_project_button
    find(".edit-project").click
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

  def when_i_clear_the_required_fields
    when_i_fill_out_the_short_title ""
    when_i_fill_out_the_title ""
    when_i_select_the_funding_status "Select a Funding Status"
  end

  def when_i_modify_the_project
    when_i_fill_out_the_short_title "Short Title"
    when_i_fill_out_the_title "Title"
    when_i_select_the_funding_status "Funded"
    when_i_select_the_funding_source "College Department"
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

  def then_i_should_see_the_updated_project
    project = Protocol.first

    expect(project.type).to eq("Project")
    expect(project.short_title).to eq("Short Title")
    expect(project.title).to eq("Title")
    expect(project.funding_status).to eq("funded")
    expect(project.funding_source).to eq("college")
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