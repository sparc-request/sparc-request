require 'rails_helper'

RSpec.describe "creating a new study that is selected for epic", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
    visit new_portal_protocol_path
  end

  describe 'submitting a form that has been selected for epic' do

    before :each do
      fill_in_study_info
      wait_for_javascript_to_finish
    end

    describe 'submitting a form that has been selected for epic' do
      it 'should return a study_type of 0' do
        select 'No', from: 'study_type_answer_certificate_of_conf_answer'
  			select 'No', from: 'study_type_answer_higher_level_of_privacy_answer'
  			select 'Yes', from: 'study_type_answer_epic_inbasket_answer'
  			select 'No', from: 'study_type_answer_research_active_answer'
  			select 'No', from: 'study_type_answer_restrict_sending_answer'
  			find('.continue_button').click
  			wait_for_javascript_to_finish
  			and_add_an_authorized_user
  			wait_for_javascript_to_finish
        save_and_open_page
  			expect(Protocol.find(study.id).determine_study_type).to eq "0"
        
      end
    end
  end

  def fill_in_study_info
	  fill_in "study_short_title", with: "Bob"
	  fill_in "study_title", with: "Dole"
	  fill_in "study_sponsor_name", with: "Captain Kurt 'Hotdog' Zanzibar"
	  select "Funded", from: "study_funding_status"
	  select "Federal", from: "study_funding_source"
	  find('#study_selected_for_epic_true').click
  end

  def and_add_an_authorized_user
    select "Primary PI", from: "project_role_role"
    find('.add-authorized-user').click
    wait_for_javascript_to_finish
    find('.continue_button').click
    wait_for_javascript_to_finish
  end

end