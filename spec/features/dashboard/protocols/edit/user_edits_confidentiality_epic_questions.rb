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
