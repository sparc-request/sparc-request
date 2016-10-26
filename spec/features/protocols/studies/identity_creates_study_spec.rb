# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.feature "User wants to create a Study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    program.update_attribute(:process_ssrs, true)
    service_request.update_attribute(:status, 'first_draft')
    study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
    visit '/'
    click_link 'South Carolina Clinical and Translational Institute (SCTR)'
    wait_for_javascript_to_finish
    click_link 'Office of Biomedical Informatics'
    wait_for_javascript_to_finish
    click_button 'Add', match: :first
    wait_for_javascript_to_finish
    click_button 'Yes'
    wait_for_javascript_to_finish
    find('.submit-request-button').click
    click_link 'New Research Study'
    wait_for_javascript_to_finish
    find('#study_selected_for_epic_false').click()
  end

  context 'and clicks the New Study button' do
    scenario 'and sees the cancel button' do
      expect(page).to have_link 'Cancel'
    end

    scenario 'and sees the continue button' do
      expect(page).to have_link 'Continue'
    end

    context 'and submits the form without filling out required fields' do
      scenario 'and sees some errors' do
        click_link 'Continue'
        page.find '#errorExplanation'
      end
    end

    context 'funding sources' do
      before :each do
        fill_in 'study_short_title', with: 'title'
        fill_in 'study_title', with: 'title'
        fill_in 'study_sponsor_name', with: 'test'
      end

      scenario 'submits the form without selecting a funding source' do
        click_link 'Continue'
        wait_for_javascript_to_finish
        expect(page).to have_content "Funding status can't be blank"
      end
    end


    context 'and submits the form after selecting Publish to Epic' do
      
      before :each do
        service_request.update_attribute(:status, 'first_draft')
        study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
        visit '/'
        click_link 'South Carolina Clinical and Translational Institute (SCTR)'
        wait_for_javascript_to_finish
        click_link 'Office of Biomedical Informatics'
        wait_for_javascript_to_finish
        click_button 'Add', match: :first
        wait_for_javascript_to_finish
        click_button 'Yes'
        wait_for_javascript_to_finish
        find('.submit-request-button').click
        click_link 'New Research Study'
        wait_for_javascript_to_finish
        when_i_fill_out_the_protocol_information
      end

      scenario 'and sees no errors' do
        when_i_select_publish_study_to_epic
        when_i_set_question_1_to "No"
        when_i_set_question_2_to "Yes"
        when_i_set_question_2b_to "No"
        when_i_set_question_3_to "No"
        when_i_set_question_4_to "No"
        when_i_set_question_5_to "No"
        when_i_submit_the_form
        then_i_should_not_see_errors_of_type 'protocol information publish to epic'
      end

      scenario 'submits the form without selecting a potential source' do
        select 'Funded', from: 'study_funding_status'
        click_link 'Continue'
        wait_for_javascript_to_finish
        expect(page).to have_content 'Funding source You must select a funding source'
      end

    end

    context 'and submits the form after filling out required fields' do
      before :each do
        fill_in 'study_short_title', with: 'title'
        fill_in 'study_title', with: 'title'
        fill_in 'study_sponsor_name', with: 'test'
        select 'Funded', from: 'study_funding_status'
        select 'College Department', from: 'study_funding_source'
        click_link 'Continue'
        wait_for_javascript_to_finish
      end

      scenario 'and sees the go back button' do
        expect(page).to have_link 'Go Back'
      end

      scenario 'and sees the save and continue button' do
        expect(page).to have_link 'Save & Continue'
      end

      context 'and looks for an additional user' do
        before :each do
          select 'Primary PI', from: 'project_role_role'
          click_button 'Add Authorized User'
          wait_for_javascript_to_finish
          fill_autocomplete('user_search_term', with: 'bjk7')
          wait_for_javascript_to_finish
          page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
          select 'PD/PI', from: 'project_role_role'
        end

        scenario 'and sees the user information' do
          expect(page).to have_content "Brian Kelsey"
          expect(page).to have_content "kelsey@musc.edu"
        end

        scenario 'and adds the authorized user' do
          click_button 'Add Authorized User'
          wait_for_javascript_to_finish
          expect(page).not_to have_content('kelsey@musc.edu')
          click_link 'Save & Continue'
          expect(page).to have_link 'Edit Study'
        end
      end
    end
  end

  def given_i_am_viewing_the_service_request_protocol_page
    visit protocol_service_request_path service_request.id
  end

  def given_i_am_viewing_the_protocol_information_page
    given_i_am_viewing_the_service_request_protocol_page
    wait_for_javascript_to_finish
    when_i_click_the_new_study_button

  end

  def when_i_search_for_the_user_name
    fill_autocomplete('user_search_term', with: 'bjk7')
  end

  def when_i_click_the_new_study_button
    click_link "New Study"
  end

  def when_i_fill_out_the_short_title short_title="Fake Short Title"
    fill_in "study_short_title", with: short_title
  end

  def when_i_fill_out_the_title title="Fake Title"
    fill_in "study_title", with: title
  end
  
  def when_i_fill_out_the_sponsor_name sponsor_name="Fake Sponsor Name"
    fill_in "study_sponsor_name", with: sponsor_name
  end

  def when_i_select_the_funding_status funding_status="Funded"
    select funding_status, from: "study_funding_status"
  end

  def when_i_select_the_funding_source funding_source="Federal"
    select funding_source, from: "study_funding_source"
  end

  def when_i_select_publish_study_to_epic publish_to_epic=true
    case publish_to_epic
      when true
        find('#study_selected_for_epic_true').click
      when false
        find('#study_selected_for_epic_false').click
      else
        puts "An unexpected value was received in when_i_select_publish_study_to_epic. Perhaps there was a typo?"
    end
  end

  def when_i_set_question_1_to selection
    select selection, from: "study_type_answer_certificate_of_conf_answer"
  end
  
  def when_i_set_question_2_to selection
    select selection, from: "study_type_answer_higher_level_of_privacy_answer"
  end

  def when_i_set_question_2b_to selection
    select selection, from: "study_type_answer_access_study_info_answer"
  end

  def when_i_set_question_3_to selection
    select selection, from: "study_type_answer_epic_inbasket_answer"
  end

  def when_i_set_question_4_to selection
    select selection, from: "study_type_answer_research_active_answer"
  end

  def when_i_set_question_5_to selection
    select selection, from: "study_type_answer_restrict_sending_answer"
  end

  def when_i_fill_out_the_protocol_information
    when_i_fill_out_the_short_title
    when_i_fill_out_the_title


    when_i_select_the_funding_status
    when_i_select_the_funding_source
    when_i_fill_out_the_sponsor_name
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

  def then_i_should_see_the_study_was_added_correctly
    study = Protocol.last

    expect(study.type).to eq("Study")
    expect(study.short_title).to eq("Fake Short Title")
    expect(study.title).to eq("Fake Title")
    expect(study.sponsor_name).to eq("Fake Sponsor Name")
    expect(study.funding_status).to eq("funded")
    expect(study.funding_source).to eq("federal")
    expect(study.selected_for_epic).to eq(false)
    expect(ServiceRequest.first.status).to_not eq("first_draft")
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

  def then_i_should_not_see_errors_of_type error_type
    case error_type
      when 'protocol information publish to epic'
        expect(page).to_not have_content("Study type questions must be selected")
      else
        puts "An unexpected error was found in then_i_should_not_see_errors_of_type. Perhaps there was a typo?"
        expect(0).to eq(1)
    end
  end
end
