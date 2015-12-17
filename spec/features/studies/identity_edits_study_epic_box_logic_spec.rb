require 'rails_helper'

RSpec.describe "Identity edits Study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request
  build_study

  before :each do
  	visit protocol_service_request_path service_request.id
    find('.edit-study').click
  end

  context 'visiting an active studys edit page' do

    before :each do 
      study.update_attributes(selected_for_epic: true)
      study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:true).pluck(:id).first)
    end

    context 'epic box answers are YES, YES, NIL, NIL, NIL, NIL' do

      before :each do
        
        active_answer1.update_attributes(answer: 1)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: nil)
        active_answer5.update_attributes(answer: nil)
        active_answer6.update_attributes(answer: nil)

        

        edit_project_study_info

      end

      it 'should display active questions 1,2' do
      	save_and_open_page
	      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to have_css('#study_type_answer_higher_level_of_privacy')
	      expect(page).to_not have_selector('#study_type_answer_access_study_info')
	      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
	      expect(page).to_not have_selector('#study_type_answer_research_active')
	      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
      end

      context 'first epic box answer is changed to NO' do

      	before do

      		select "No", from: 'study_type_answer_certificate_of_conf_answer'
      		wait_for_javascript_to_finish

      	end

	      it 'should have No for the active question 1 and nothing selected for active question 2' do
	      	
	      	expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
	      	expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Select One')

	      end
	    end
    end
    # context 'epic box answers are NO, YES, NO, NO, NO, NO' do

    #   before :each do
        
    #     active_answer1.update_attributes(answer: 0)
    #     active_answer2.update_attributes(answer: 1)
    #     active_answer3.update_attributes(answer: 0)
    #     active_answer4.update_attributes(answer: 0)
    #     active_answer5.update_attributes(answer: 0)
    #     active_answer6.update_attributes(answer: 0)

    #     edit_project_study_info

    #   end

    #   it 'should display all active questions ' do

	   #    expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	   #    expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
	   #    expect(page).to have_selector('#study_type_answer_access_study_info')
	   #    expect(page).to have_selector('#study_type_answer_epic_inbasket')
	   #    expect(page).to have_selector('#study_type_answer_research_active')
	   #    expect(page).to have_selector('#study_type_answer_restrict_sending') 
    #   end

    #   context 'first epic box answer is changed to YES' do

    #   	before do

    #   		select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
    #   		wait_for_javascript_to_finish

    #   	end

	   #    it 'should have No for the active question 1 and nothing selected for active question 2' do
	      	
	   #    	expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
	   #    	expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Select One')

	   #    end
	   #  end
		  # context 'first epic box answer is changed to YES' do

    #   	before do

    #   		select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
    #   		wait_for_javascript_to_finish

    #   	end

	   #    it 'should have No for the active question 1 and nothing selected for active question 2' do
	      	
	   #    	expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
	   #    	expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Select One')

	   #    end
	   #  end
    # end
  end

  def edit_project_study_info
    study.reload
    visit protocol_service_request_path service_request.id
  	find('.edit-study').click
    wait_for_javascript_to_finish
  end
end