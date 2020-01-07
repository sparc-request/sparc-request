# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe 'User edits study type questions', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  before :each do
    org     = create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1)
    service = create(:service, name: "Service", abbreviation: "Service", organization: org, pricing_map_count: 1)
    @sr     = create(:service_request_without_validations, status: 'first_draft')
    ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: org, status: 'first_draft')
              create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
  end

  context 'Using Epic' do
    stub_config("use_epic", true)

    before :each do
      visit new_protocol_path(type: Study.name)
    end

    it 'should show notes for various scenarios' do
      find("[for='protocol_selected_for_epic_true']").click

      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'Yes'
      wait_for_javascript_to_finish

      expect(page).to have_content('De-identified Research Participant')

      bootstrap_select '#study_type_answer_certificate_of_conf_answer', 'No'
      bootstrap_select '#study_type_answer_higher_level_of_privacy_answer', 'No'
      bootstrap_select '#study_type_answer_epic_inbasket_answer', 'No'
      bootstrap_select '#study_type_answer_research_active_answer', 'No'
      bootstrap_select '#study_type_answer_restrict_sending_answer', 'No'
      wait_for_javascript_to_finish

      expect(page).to have_content('Full Epic Functionality: no notification, no pink header, no MyChart access.')

      find("[for='protocol_selected_for_epic_false']").click

      expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[5], normalize_ws: true)

      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      wait_for_javascript_to_finish

      expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[6], normalize_ws: true)
    end
  end

  context 'Not Using Epic' do
    stub_config("use_epic", false)

    before :each do
      visit new_protocol_path(type: Study.name)
    end

    it 'should show questions but not notes' do
      bootstrap_select '#study_type_answer_certificate_of_conf_no_epic_answer', 'No'
      expect(page).to have_content(STUDY_TYPE_QUESTIONS_VERSION_3[6], normalize_ws: true)

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
