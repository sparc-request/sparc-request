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

RSpec.describe 'User creates study', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  def visit_create_study_form
    visit protocol_service_request_path(@sr)
    page.find('.new-study').click
    wait_for_javascript_to_finish
  end


  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, name: "Program", parent: provider, process_ssrs: true, pricing_setup_count: 1)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program, pricing_map_count: 1)
    @sr         = create(:service_request_without_validations, status: 'first_draft')
    ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
    allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
  end

  context 'Using Epic' do
    stub_config("use_epic", true)

    context 'selects "Publish Study in Epic" and selects answers that give study_type 1' do
      scenario 'should show note for study_type 1' do
        visit_create_study_form
        wait_for_javascript_to_finish

        find('#study_selected_for_epic_true_button').click
        wait_for_javascript_to_finish

        bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
        wait_for_javascript_to_finish

        expect(page).to have_content('De-identified Research Participant')
      end
    end
    context 'selects "Publish Study in Epic" and selects answers that give study_type 11' do
      scenario 'should show note for study_type 1' do
        visit_create_study_form
        wait_for_javascript_to_finish

        find('#study_selected_for_epic_true_button').click
        wait_for_javascript_to_finish

        bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'No'
        bootstrap_select '#study_type_answer_higher_level_of_privacy_answer', 'No'
        bootstrap_select '#study_type_answer_epic_inbasket_answer', 'No'
        bootstrap_select '#study_type_answer_research_active_answer', 'No'
        bootstrap_select '#study_type_answer_restrict_sending_answer', 'No'
        wait_for_javascript_to_finish

        expect(page).to have_content('Full Epic Functionality: no notification, no pink header, no MyChart access.')
      end
    end

    context 'selects "No" to "Publish Study in Epic"' do
      it 'should show questions without Epic language' do
        visit_create_study_form
        wait_for_javascript_to_finish

        find('#study_selected_for_epic_false_button').click
        wait_for_javascript_to_finish

        expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[5], normalize_ws: true)

        bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
        wait_for_javascript_to_finish

        expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[6], normalize_ws: true)
      end
    end
  end

  context 'Not Using Epic' do
    stub_config('use_epic', false)

    before :each do
      visit_create_study_form
      wait_for_javascript_to_finish
    end

    it 'defaults to the "No" answer for the epic question' do
      expect(page).not_to have_selector('#study_selected_for_epic_true_button')
      expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[5], normalize_ws: true)
    end

    it 'shows the second question when "No" is selected for the first' do
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[6], normalize_ws: true)
    end

    it 'does not show notes when the form is completed' do
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'Yes'
      wait_for_javascript_to_finish
      expect(page).not_to have_selector('#study_type_note')
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'Yes'
      wait_for_javascript_to_finish
      expect(page).not_to have_selector('#study_type_note')
      bootstrap_select '#study_type_answer_higher_level_of_privacy_no_epic_answer', 'No'
      wait_for_javascript_to_finish
      expect(page).not_to have_selector('#study_type_note')
    end
  end
end
