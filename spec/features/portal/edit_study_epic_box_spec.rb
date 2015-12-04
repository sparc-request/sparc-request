require 'rails_helper'

RSpec.describe "edit study epic box", js: true do
	let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  let(:numerical_day) { Date.today.strftime("%d").gsub(/^0/,'') }

  before :each do
    visit edit_portal_protocol_path service_request.protocol.id
    wait_for_javascript_to_finish
    find('#study_selected_for_epic_true').click
  end
  # 1: 'study_type_answer_certificate_of_conf_answer'
  # 2: 'study_type_answer_higher_level_of_privacy_answer'
  # 2b:'study_type_answer_access_study_info_answer'
  # 3: '#study_type_answer_epic_inbasket', 
  # 4: '#study_type_answer_research_active', 
  # 5: '#study_type_answer_restrict_sending']

  scenario "Study type equals 1" do 
  	
  	select 'Yes', from: 'study_type_answer_certificate_of_conf_answer'
  	select 'Yes', from: 'study_type_answer_higher_level_of_privacy_answer'
  	expect(page).to_not have_selector('#study_type_answer_access_study_info')
  	expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
  	expect(page).to_not have_selector('#study_type_answer_research_active')
  	expect(page).to_not have_selector('#study_type_answer_restrict_sending')
  	click_button "Save"
  end

  scenario "Study type equals 2" do 

  	select 'No', from: 'study_type_answer_certificate_of_conf_answer'
  	select 'Yes', from: 'study_type_answer_higher_level_of_privacy_answer'
  	select 'Yes', from: 'study_type_answer_access_study_info_answer'
  	expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
  	expect(page).to_not have_selector('#study_type_answer_research_active')
  	expect(page).to_not have_selector('#study_type_answer_restrict_sending')
  end

  scenario "Study type equals 5" do
  	select 'No', from: 'study_type_answer_certificate_of_conf_answer'
  	select 'Yes', from: 'study_type_answer_higher_level_of_privacy_answer'
  	select 'No', from: 'study_type_answer_access_study_info_answer'
  	select 'No', from: 'study_type_answer_epic_inbasket'
  	select 'Yes', from: 'study_type_answer_research_active'
  	select 'No', from: 'study_type_answer_restrict_sending'
  end

  scenario "Study type equals 14" do
  	select 'No', from: 'study_type_answer_certificate_of_conf_answer'
  	select 'No', from: 'study_type_answer_higher_level_of_privacy_answer'
  	expect(page).to_not have_selector('#study_type_answer_access_study_info')
  	expect(page).to have_selector('#study_type_answer_epic_inbasket')
  	expect(page).to have_selector('#study_type_answer_research_active')
  	expect(page).to have_selector('#study_type_answer_restrict_sending')
  end
end