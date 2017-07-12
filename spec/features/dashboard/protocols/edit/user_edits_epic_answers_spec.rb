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
                              organization: organization)
  end

  context 'use epic = true' do

    scenario 'Study, selected for epic: false, question group 3' do
      @protocol.update_attribute(:selected_for_epic, false)
      @protocol.update_attribute(:study_type_question_group_id, 3)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      find('.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      find('#study_selected_for_epic_true_button').click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click

      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'Yes')
        expect(page).to have_css('a.edit-answers')
      end
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
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click


      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
    end

    scenario 'Study, selected for epic: true, question group 3' do
      @protocol.update_attribute(:selected_for_epic, true)
      @protocol.update_attribute(:study_type_question_group_id, 3)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      find('.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      find('#study_selected_for_epic_true_button').click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click

      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'Yes')
        expect(page).to have_css('a.edit-answers')
      end

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
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click


      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
    end

    scenario 'Study, selected for epic: true, question group 2' do
      @protocol.update_attribute(:selected_for_epic, true)
      @protocol.update_attribute(:study_type_question_group_id, 2)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      find('.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      find('#study_selected_for_epic_true_button').click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click

      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'Yes')
        expect(page).to have_css('a.edit-answers')
      end

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
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click


      within '#study_type_answer_certificate_of_conf' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
    end
  end

  context 'use epic = false' do

    before(:each) do
      stub_const('USE_EPIC', false)
    end

    scenario 'Study, selected for epic: false, question group 3' do
      @protocol.update_attribute(:selected_for_epic, false)
      @protocol.update_attribute(:study_type_question_group_id, 3)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      find('.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click

      within '#study_type_answer_certificate_of_conf_no_epic' do
        expect(page).to have_css('div.col-lg-4', text: 'Yes')
        expect(page).to have_css('a.edit-answers')
      end

      find('a.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click


      within '#study_type_answer_certificate_of_conf_no_epic' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
    end

    scenario 'Study, selected for epic: true, question group 3' do
      @protocol.update_attribute(:selected_for_epic, true)
      @protocol.update_attribute(:study_type_question_group_id, 3)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      find('.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click

      within '#study_type_answer_certificate_of_conf_no_epic' do
        expect(page).to have_css('div.col-lg-4', text: 'Yes')
        expect(page).to have_css('a.edit-answers')
      end

      find('a.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click


      within '#study_type_answer_certificate_of_conf_no_epic' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
    end

    scenario 'Study, selected for epic: true, question group 2' do
      @protocol.update_attribute(:selected_for_epic, true)
      @protocol.update_attribute(:study_type_question_group_id, 2)
      visit edit_dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      find('.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click

      within '#study_type_answer_certificate_of_conf_no_epic' do
        expect(page).to have_css('div.col-lg-4', text: 'Yes')
        expect(page).to have_css('a.edit-answers')
      end

      find('a.edit-answers', match: :first).click
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      click_button 'Save'
      wait_for_javascript_to_finish
      find('.edit-protocol-information-button').click


      within '#study_type_answer_certificate_of_conf_no_epic' do
        expect(page).to have_css('div.col-lg-4', text: 'No')
        expect(page).to have_css('a.edit-answers')
      end
    end
  end
end

