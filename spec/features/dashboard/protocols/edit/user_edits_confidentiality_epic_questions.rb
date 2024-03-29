# Copyright © 2011-2023 MUSC Foundation for Research Development
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

RSpec.describe 'User wants to edit a Protocol', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  before :each do
    @protocol = create(:study_federally_funded, primary_pi: jug2)

    visit dashboard_protocol_path(@protocol)
    wait_for_javascript_to_finish
    click_link I18n.t('protocols.edit', protocol_type: @protocol.model_name.human)
    wait_for_javascript_to_finish
  end

  describe "When 'use epic' is no but 'human subjects' is checked" do
    before do
      find(:xpath, "//label[contains(text(),'Human Subjects')]").click
      wait_for_javascript_to_finish
    end

    it "displays the 'Confidentiality and Epic Questions' container" do
      expect(page).to have_selector('#studyTypeQuestionsContainer:not(.d-none)')
    end

    it "displays the first 'no epic' Study Type Question" do
      expect(page).not_to have_selector('#study_type_answer_certificate_of_conf_no_epic_answer .form-row.d-none')
    end

    it "displays the second 'no epic' Study Type Question when the first question has no selected" do
      expect(page).not_to have_selector('#study_type_answer_higher_level_of_privacy_no_epic_answer .form-row.d-none')
    end
  end

  describe "When 'use epic' is yes" do
    before do
      @protocol.update_attribute(:selected_for_epic, true)
      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish
      click_link I18n.t('protocols.edit', protocol_type: @protocol.model_name.human)
      wait_for_javascript_to_finish
    end

    it "displays the 'Confidentiality and Epic Questions' container" do
      expect(page).to have_selector('#studyTypeQuestionsContainer:not(.d-none)')
    end

    it "displays the first 'epic' Study Type Question" do
      expect(page).not_to have_selector('#study_type_answer_certificate_of_conf_answer .form-row.d-none')
    end

    it "displays the second 'epic' Study Type Question when the first question has no selected" do
      expect(page).not_to have_selector('#study_type_answer_higher_level_of_privacy_answer .form-row.d-none')
    end
  end
end
