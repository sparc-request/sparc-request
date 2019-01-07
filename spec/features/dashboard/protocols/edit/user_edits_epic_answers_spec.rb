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

RSpec.describe 'User edits epic answers', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  before :each do
    @protocol       = create(:protocol_without_validations,
                              type: "Study",
                              primary_pi: jug2,
                              funding_status: "funded",
                              funding_source: "foundation")
    organization    = create(:organization)
    service_request = create(:service_request_without_validations,
                              protocol: @protocol)
                      create(:sub_service_request_without_validations,
                              organization: organization,
                              service_request: service_request,
                              status: 'draft')
                      create(:super_user, identity: jug2,
                              organization: organization,
                              access_empty_protocols: true)
    
    allow(Protocol).to receive(:rmid_status).and_return(true)
  end

  context 'use epic = true' do
    stub_config("use_epic", true)
    
    scenario 'Study, selected for epic: false, question group 3' do
      @protocol.update_attribute(:selected_for_epic, false)
      @protocol.update_attribute(:study_type_question_group_id, 3)

      ### INITIAL EDIT ###
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      ### EDIT STUDY TYPE ANSWERS ###
      edit_study_type_answers_selected_for_epic_true_cofc_true_and_see_note

      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))

      ### GO BACK INTO EDIT ###
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      ### SEE THAT CORRECT ANSWERS ARE DISPLAYED WITH CORRECT NOTE ###
      and_sees_correct_answers_for_selected_for_epic_true_and_cofc_true

      ### EDIT STUDY TYPE ANSWERS ###
      find('a.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_higher_level_of_privacy_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_epic_inbasket_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_research_active_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_restrict_sending_answer', 'No'
      wait_for_javascript_to_finish
      expect(page).to have_selector('#study_type_note', text: 'Note: Full Epic Functionality: no notification, no pink header, no MyChart access.')

      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))

      ### EDIT AGAIN TO SEE CORRRECT ANSWERS AND NOTE DISPLAYED ###
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end

      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      within '#study_type_answer_higher_level_of_privacy' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end

      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      within '#study_type_answer_epic_inbasket' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end

      expect(page).to have_selector('#study_type_answer_research_active')
      within '#study_type_answer_research_active' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end

      expect(page).to have_selector('#study_type_answer_restrict_sending')
      within '#study_type_answer_restrict_sending' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
      expect(page).to have_selector('#study_type_note', text: 'Note: Full Epic Functionality: no notification, no pink header, no MyChart access.')
    end

    scenario 'Study, selected for epic: true, question group 3' do
      @protocol.update_attribute(:selected_for_epic, true)
      @protocol.update_attribute(:study_type_question_group_id, 3)

      ### INITIAL EDIT ###
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      ### EDIT STUDY TYPE ANSWERS ###
      edit_study_type_answers_selected_for_epic_false_cofc_true_and_see_no_note(true)

      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))

      ### GO BACK INTO EDIT ###
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      ### SEE THAT CORRECT ANSWERS ARE DISPLAYED ###
      and_sees_the_correct_answer_and_no_note_displayed(true)

      ### EDIT STUDY TYPE ANSWERS ###
      edit_study_type_answers_all_answers_no_and_no_note(true)

      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))

      ### EDIT AGAIN TO SEE CORRRECT ANSWERS ARE DISPLAYED ###
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      and_sees_the_correct_answers_and_no_note(true)
    end

    context 'Study, selected for epic: true, question group 2' do
      before :each do
        setup_data_for_version_2_study
      end

      it 'should show version 2 stq and sta when canceling an edit' do
        ### INITIAL EDIT ###
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        ### EXPECT TO SEE VERSION 2 STUDY TYPE QUESTIONS/ANSWERS ###
        version_2_study_type_questions_and_answers_are_displayed

        edit_study_type_answers_selected_for_epic_true_cofc_true_and_see_note

        ### EXPECT TO SEE VERSION 2 STUDY TYPE QUESTIONS/ANSWERS WHEN YOU CANCEL EDIT ###
        find('.cancel-edit', match: :first).click
        wait_for_javascript_to_finish
        version_2_study_type_questions_and_answers_are_displayed
        @protocol.reload
      end

      it 'display newly saved study type answers' do

        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        edit_study_type_answers_selected_for_epic_true_cofc_true_and_see_note

        click_button 'Save'
        wait_for_page(dashboard_protocol_path(@protocol))

        ### SEE THAT CORRECT ANSWER IS DISPLAYING ###
        find('.edit-protocol-information-button').click
        wait_for_page(edit_dashboard_protocol_path(@protocol))

        and_sees_correct_answers_for_selected_for_epic_true_and_cofc_true
      end
    end
  end

  context 'use epic = false' do
    stub_config('use_epic', false)
    scenario 'Study, selected for epic: false, question group 3' do
      @protocol.update_attribute(:selected_for_epic, false)
      @protocol.update_attribute(:study_type_question_group_id, 3)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      edit_study_type_answers_selected_for_epic_false_cofc_true_and_see_no_note(false)
      
      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      and_sees_the_correct_answer_and_no_note_displayed(false)
      ### SEE APPROPRIATE STUDY TYPE NOTE ###
      expect(page).not_to have_selector('#study_type_note')

      edit_study_type_answers_all_answers_no_and_no_note(false)

      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      and_sees_the_correct_answers_and_no_note(false)
    end

    scenario 'Study, selected for epic: true, question group 3' do
      @protocol.update_attribute(:selected_for_epic, true)
      @protocol.update_attribute(:study_type_question_group_id, 3)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      edit_study_type_answers_selected_for_epic_false_cofc_true_and_see_no_note(false)

      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))

      and_sees_the_correct_answer_and_no_note_displayed(false)

      ### SEE APPROPRIATE STUDY TYPE NOTE ###
      expect(page).not_to have_selector('#study_type_note')

      edit_study_type_answers_all_answers_no_and_no_note(false)
      
      click_button 'Save'
      wait_for_page(dashboard_protocol_path(@protocol))
      find('.edit-protocol-information-button').click
      wait_for_page(edit_dashboard_protocol_path(@protocol))


      and_sees_the_correct_answers_and_no_note(false)
    end

    context 'Study, selected for epic: true, question group 2' do
      before :each do
        setup_data_for_version_2_study
      end

      it 'should ignore the version 2 questions since USE_EPIC is false' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        expect(page).to_not have_css('#study_selected_for_epic_true_button') 

        edit_study_type_answers_selected_for_epic_false_cofc_true_and_see_no_note(false)

        click_button 'Save'
        wait_for_page(dashboard_protocol_path(@protocol))
        find('.edit-protocol-information-button').click
        wait_for_page(edit_dashboard_protocol_path(@protocol))

        and_sees_the_correct_answer_and_no_note_displayed(false)

        expect(page).to_not have_css('#study_type_answer_higher_level_of_privacy_no_epic')

        edit_study_type_answers_all_answers_no_and_no_note(false)

        click_button 'Save'
        wait_for_page(dashboard_protocol_path(@protocol))
        find('.edit-protocol-information-button').click
        wait_for_page(edit_dashboard_protocol_path(@protocol))

        and_sees_the_correct_answers_and_no_note(false)
      end
    end

    context 'Study, selected for epic: false, question group 3' do
      scenario 'Edit Study, answer "No" for first question and do not answer second question' do
        @protocol.update_attribute(:selected_for_epic, false)
        @protocol.update_attribute(:study_type_question_group_id, 3)
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish
        
        find('.edit-answers', match: :first).click
        wait_for_javascript_to_finish

        expect(page).to_not have_css('#study_selected_for_epic_true_button') 
        bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
        wait_for_javascript_to_finish
        expect(page).not_to have_selector('#study_type_note')

        click_button 'Save'
        wait_for_page(dashboard_protocol_path(@protocol))
        find('.edit-protocol-information-button').click
        wait_for_page(edit_dashboard_protocol_path(@protocol))

        expect(page).to have_selector('#study_type_answer_certificate_of_conf_no_epic')
        within '#study_type_answer_certificate_of_conf_no_epic' do
          expect(page).to have_css('div.col-lg-4', text: 'No')
          expect(page).to have_css('a.edit-answers')
        end

        expect(page).to have_selector('#study_type_answer_higher_level_of_privacy_no_epic')
        within '#study_type_answer_higher_level_of_privacy_no_epic' do
          expect(page).to have_css('div.col-lg-4', text: '')
          expect(page).to have_css('a.edit-answers')
        end

        ### SEE APPROPRIATE STUDY TYPE NOTE ###
        expect(page).not_to have_selector('#study_type_note')
      end
    end
  end

  def version_2_study_type_questions_and_answers_are_displayed
    expect(page).to have_selector('#study_type_answer_certificate_of_conf')
    within '#study_type_answer_certificate_of_conf' do
      expect(page).to have_text(stq_certificate_of_conf_version_2.question)
      expect(page).to have_css('div.col-lg-4', text: 'No')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
    within '#study_type_answer_higher_level_of_privacy' do
      expect(page).to have_text(stq_higher_level_of_privacy_version_2.question)
      expect(page).to have_css('div.col-lg-4', text: 'Yes')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to have_selector('#study_type_answer_access_study_info')
     within '#study_type_answer_access_study_info' do
      expect(page).to have_text(stq_access_study_info_version_2.question)
      expect(page).to have_css('div.col-lg-4', text: 'No')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to have_selector('#study_type_answer_epic_inbasket')
    within '#study_type_answer_epic_inbasket' do
      expect(page).to have_text(stq_epic_inbasket_version_2.question)
      expect(page).to have_css('div.col-lg-4', text: 'No')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to have_selector('#study_type_answer_research_active')
    within '#study_type_answer_research_active' do
      expect(page).to have_text(stq_research_active_version_2.question)
      expect(page).to have_css('div.col-lg-4', text: 'Yes')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to have_selector('#study_type_answer_restrict_sending')
    within '#study_type_answer_restrict_sending' do
      expect(page).to have_text(stq_restrict_sending_version_2.question)
      expect(page).to have_css('div.col-lg-4', text: 'Yes')
      expect(page).to have_css('a.edit-answers')
    end
  end

  def edit_study_type_answers_selected_for_epic_true_cofc_true_and_see_note
    find('.edit-answers', match: :first).click
    wait_for_javascript_to_finish
    find('#study_selected_for_epic_true_button').click
    wait_for_javascript_to_finish
    bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
    wait_for_javascript_to_finish
    expect(page).to have_selector('#study_type_note', text: 'Note: De-identified Research Participant')
  end

  def and_sees_correct_answers_for_selected_for_epic_true_and_cofc_true
    expect(page).to have_selector('#study_type_answer_certificate_of_conf')
    within '#study_type_answer_certificate_of_conf' do
      expect(page).to have_css('div.col-lg-4', text: 'Yes')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to_not have_css('#study_type_answer_higher_level_of_privacy') 
    expect(page).to_not have_css('#study_type_answer_epic_inbasket')
    expect(page).to_not have_css('#study_type_answer_research_active')
    expect(page).to_not have_css('#study_type_answer_restrict_sending')
    expect(page).to have_selector('#study_type_note', text: 'Note: De-identified Research Participant')
  end

  def edit_study_type_answers_selected_for_epic_false_cofc_true_and_see_no_note(use_epic)
    find('.edit-answers', match: :first).click
    wait_for_javascript_to_finish
    if use_epic
      find('#study_selected_for_epic_false_button').click
      wait_for_javascript_to_finish
    else
      expect(page).to_not have_css('#study_selected_for_epic_true_button') 
    end  
    bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
    wait_for_javascript_to_finish
    ### SEE APPROPRIATE STUDY TYPE NOTE ###
    if use_epic
      expect(page).to have_selector('#study_type_note', text: "", visible: false)
    else
      expect(page).not_to have_selector('#study_type_note')
    end
  end

  def edit_study_type_answers_all_answers_no_and_no_note(use_epic)
    expect(page).to_not have_css('#study_type_answer_higher_level_of_privacy_no_epic_answer') 
    find('a.edit-answers', match: :first).click
    wait_for_javascript_to_finish
    bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
    wait_for_javascript_to_finish
    bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'No'
    wait_for_javascript_to_finish
    ### SEE APPROPRIATE STUDY TYPE NOTE ###
    if use_epic
      expect(page).to have_selector('#study_type_note', text: "", visible: false)
    else
      expect(page).not_to have_selector('#study_type_note')
    end
  end

  def and_sees_the_correct_answer_and_no_note_displayed(use_epic)
    expect(page).to have_selector('#study_type_answer_certificate_of_conf_no_epic')
    within '#study_type_answer_certificate_of_conf_no_epic' do
      expect(page).to have_css('div.col-lg-4', text: 'Yes')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to_not have_css('#study_type_answer_higher_level_of_privacy_no_epic')

    if use_epic
      expect(page).to have_selector('#study_type_note', text: "", visible: false)
    else
      expect(page).not_to have_selector('#study_type_note')
    end
  end

  def and_sees_the_correct_answers_and_no_note(use_epic)
    expect(page).to have_selector('#study_type_answer_certificate_of_conf_no_epic')
    within '#study_type_answer_certificate_of_conf_no_epic' do
      expect(page).to have_css('div.col-lg-4', text: 'No')
      expect(page).to have_css('a.edit-answers')
    end

    expect(page).to have_selector('#study_type_answer_higher_level_of_privacy_no_epic')
    within '#study_type_answer_higher_level_of_privacy_no_epic' do
      expect(page).to have_css('div.col-lg-4', text: 'No')
      expect(page).to have_css('a.edit-answers')
    end

    if use_epic
      expect(page).to have_selector('#study_type_note', text: "", visible: false)
    else
      expect(page).not_to have_selector('#study_type_note')
    end
  end

  def setup_data_for_version_2_study
    ### STQ GROUP ###
    @study_type_question_group_version_2 = StudyTypeQuestionGroup.create(active: false, version: 2)
    ### STQ'S ###
    @stq_certificate_of_conf_version_2 = StudyTypeQuestion.create("order"=>1, "question"=>"1. Does your study have a Certificate of Confidentiality?", "friendly_id"=>"certificate_of_conf", "study_type_question_group_id" => study_type_question_group_version_2.id) 
    @stq_higher_level_of_privacy_version_2 = StudyTypeQuestion.create("order"=>2, "question"=>"2. Does your study require a higher level of privacy for the participants?", "friendly_id"=>"higher_level_of_privacy", "study_type_question_group_id" => study_type_question_group_version_2.id) 
    @stq_access_study_info_version_2 = StudyTypeQuestion.create("order"=>3, "question"=>"2b. Do participants enrolled in your study require a second DEIDENTIFIED Medical Record that is not connected to their primary record in Epic?", "friendly_id"=>"access_study_info", "study_type_question_group_id" => study_type_question_group_version_2.id) 
    @stq_epic_inbasket_version_2 = StudyTypeQuestion.create("order"=>4, "question"=>"3. Do you wish to receive a notification via Epic InBasket when your research participants are admitted to the hospital or ED?", "friendly_id"=>"epic_inbasket", "study_type_question_group_id" => study_type_question_group_version_2.id) 
    @stq_research_active_version_2 = StudyTypeQuestion.create("order"=>5, "question"=>"4. Do you wish to remove the 'Research: Active' indicator in the Patient Header for your study participants?", "friendly_id"=>"research_active", "study_type_question_group_id" => study_type_question_group_version_2.id) 
    @stq_restrict_sending_version_2 = StudyTypeQuestion.create("order"=>6, "question"=>"5. Do you need to restrict the sending of study related results, such as laboratory and radiology results, to a participants MyChart?", "friendly_id"=>"restrict_sending", "study_type_question_group_id" => study_type_question_group_version_2.id) 

    ### ST ANSWERS ###
    StudyTypeAnswer.create(protocol_id: @protocol.id, study_type_question_id: stq_certificate_of_conf_version_2.id, answer: 0)
    StudyTypeAnswer.create(protocol_id: @protocol.id, study_type_question_id: stq_higher_level_of_privacy_version_2.id, answer: 1)
    StudyTypeAnswer.create(protocol_id: @protocol.id, study_type_question_id: stq_access_study_info_version_2.id, answer: 0)
    StudyTypeAnswer.create(protocol_id: @protocol.id, study_type_question_id: stq_epic_inbasket_version_2.id, answer: 0)
    StudyTypeAnswer.create(protocol_id: @protocol.id, study_type_question_id: stq_research_active_version_2.id, answer: 1)
    StudyTypeAnswer.create(protocol_id: @protocol.id, study_type_question_id: stq_restrict_sending_version_2.id, answer: 1)

    @protocol.update_attribute(:selected_for_epic, true)
    @protocol.update_attribute(:study_type_question_group_id, @study_type_question_group_version_2.id)
    @active_study_type_group = StudyTypeQuestionGroup.create(active: true, version: 3)
  end
end

