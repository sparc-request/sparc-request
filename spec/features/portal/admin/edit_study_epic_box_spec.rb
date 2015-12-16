require 'rails_helper'

RSpec.describe 'editing a studys epic box', js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:numerical_day) { Date.today.strftime('%d').gsub(/^0/, '') }

  before :each do
    add_visits
    study.update_attributes(potential_funding_start_date: (Time.now + 1.day))
    visit portal_admin_sub_service_request_path sub_service_request.id
    click_on('Project/Study Information')
    wait_for_javascript_to_finish
  end

  context 'visiting a studys edit page and the study is not selected for epic' do
    it 'should only display that it is not chosen for epic' do
      study.update_attributes(selected_for_epic: false)
      expect(page).to_not have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_text('No')
    end
  end

  context 'visiting a studys edit page and the study is selected for epic' do
    before do
      study.update_attributes(selected_for_epic: true)

      active_answer1.update_attributes(answer: 1)
      active_answer2.update_attributes(answer: 1)
      active_answer3.update_attributes(answer: nil)
      active_answer4.update_attributes(answer: nil)
      active_answer5.update_attributes(answer: nil)
      active_answer6.update_attributes(answer: nil)
      
    end
    it 'should only display data' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
      expect(page).to_not have_selector('#study_type_answer_research_active')
      expect(page).to_not have_selector('#study_type_answer_restrict_sending')
      
    end
  end

end