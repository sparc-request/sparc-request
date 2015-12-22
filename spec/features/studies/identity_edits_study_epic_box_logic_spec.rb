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

    context 'epic box answers are 1: YES, YES, NIL, NIL, NIL, NIL' do

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
      	
	      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
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
	      	expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
	      	expect(page).to have_selector('#study_type_answer_access_study_info')
		      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
		      expect(page).to_not have_selector('#study_type_answer_research_active')
		      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

	      end
	    end
    end
    context 'epic box answers are 6: NO, YES, NO, NO, NO, NO' do

      before :each do
        
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 0)
        active_answer4.update_attributes(answer: 0)
        active_answer5.update_attributes(answer: 0)
        active_answer6.update_attributes(answer: 0)

        edit_project_study_info

      end

      it 'should display all active questions ' do
      	wait_for_javascript_to_finish
      
	      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
	      expect(page).to have_selector('#study_type_answer_access_study_info')
	      expect(page).to have_selector('#study_type_answer_epic_inbasket')
	      expect(page).to have_selector('#study_type_answer_research_active')
	      expect(page).to have_selector('#study_type_answer_restrict_sending') 
      end

      context 'first epic box answer is changed to YES' do

      	before do

      		select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
      		wait_for_javascript_to_finish

      	end

	      it 'should have No for the active question 1 and display question 2' do
	      	
	      	expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
	      	expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
		      expect(page).to_not have_selector('#study_type_answer_access_study_info')
		      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
		      expect(page).to_not have_selector('#study_type_answer_research_active')
		      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

	      end
	    end
    end
    context 'epic box answers are 2: NO, YES, YES, NIL, NIL, NIL' do

      before :each do
        
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 1)
        active_answer3.update_attributes(answer: 1)
        active_answer4.update_attributes(answer: nil)
        active_answer5.update_attributes(answer: nil)
        active_answer6.update_attributes(answer: nil)

        edit_project_study_info

      end

      it 'should display questions 1,2,2b ' do
      	wait_for_javascript_to_finish
      
	      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
	      expect(page).to have_selector('#study_type_answer_access_study_info')
	      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
	      expect(page).to_not have_selector('#study_type_answer_research_active')
	      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
      end
    end
    context 'epic box answers are 15: NO, NO, NIL, YES, YES, YES' do

      before :each do
        
        active_answer1.update_attributes(answer: 0)
        active_answer2.update_attributes(answer: 0)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: 1)
        active_answer5.update_attributes(answer: 1)
        active_answer6.update_attributes(answer: 1)

        edit_project_study_info

      end

      it 'should display 1,2,3,4,5 ' do
      	wait_for_javascript_to_finish

	      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
	      expect(page).to_not have_selector('#study_type_answer_access_study_info')
	      expect(page).to have_selector('#study_type_answer_epic_inbasket')
	      expect(page).to have_selector('#study_type_answer_research_active')
	      expect(page).to have_selector('#study_type_answer_restrict_sending') 
      end
    end
  end
  context 'visiting an inactive studys edit page' do
  	before :each do 
      study.update_attributes(selected_for_epic: true)
      study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:false).pluck(:id).first)
    end

    context 'epic box answers are 1: NIL, NIL, NIL, NIL, NIL, NIL' do

      before :each do
        
        active_answer1.update_attributes(answer: nil)
        active_answer2.update_attributes(answer: nil)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: nil)
        active_answer5.update_attributes(answer: nil)
        active_answer6.update_attributes(answer: nil)   

        edit_project_study_info

      end

      it 'should display active questions 1,2' do
      	
	      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
	      expect(page).to_not have_selector('#study_type_answer_access_study_info')
	      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
	      expect(page).to_not have_selector('#study_type_answer_research_active')
	      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
      end
    end
  end
  context 'visiting an inactive studys edit page that is not selected for epic' do
  	before :each do 
      study.update_attributes(selected_for_epic: false)
      study.update_attributes(study_type_question_group_id: StudyTypeQuestionGroup.where(active:false).pluck(:id).first)
    end

    context 'epic box answers are 1: NIL, NIL, NIL, NIL, NIL, NIL' do

      before :each do
        
        active_answer1.update_attributes(answer: nil)
        active_answer2.update_attributes(answer: nil)
        active_answer3.update_attributes(answer: nil)
        active_answer4.update_attributes(answer: nil)
        active_answer5.update_attributes(answer: nil)
        active_answer6.update_attributes(answer: nil)

        edit_project_study_info

      end

      it 'should not display any epic box questions' do
      	
	      expect(page).to_not have_selector('#study_type_answer_certificate_of_conf')
	      expect(page).to_not have_selector('#study_type_answer_higher_level_of_privacy')
	      expect(page).to_not have_selector('#study_type_answer_access_study_info')
	      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
	      expect(page).to_not have_selector('#study_type_answer_research_active')
	      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
      end
    end
  end

  def edit_project_study_info
    study.reload
    visit protocol_service_request_path service_request.id
  	find('.edit-study').click
    wait_for_javascript_to_finish
  end
end