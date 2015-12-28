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
    # find('#study_selected_for_epic_true').click
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

      it 'should show 1,2' do
        
        expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
        expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
        expect(page).to_not have_selector('#study_type_answer_access_study_info')
        expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
        expect(page).to_not have_selector('#study_type_answer_research_active')
        expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

      end

      context 'change 1. to No' do

        before do

          select "No", from: 'study_type_answer_certificate_of_conf_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. No, and show 2 and 2b' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
          expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
          expect(page).to have_selector('#study_type_answer_access_study_info')
          expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
          expect(page).to_not have_selector('#study_type_answer_research_active')
          expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

        end
      end
      context 'change 1. to YES and 2. to NO' do

        before do

          select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
          select "No", from: 'study_type_answer_higher_level_of_privacy_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. YES and 2. NO' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'No')
          expect(page).to_not have_selector('#study_type_answer_access_study_info')
          expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
          expect(page).to_not have_selector('#study_type_answer_research_active')
          expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

        end
      end
      context 'change 1. to YES and 2. to YES' do

        before do

          select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
          select "Yes", from: 'study_type_answer_higher_level_of_privacy_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. YES and 2.YES ' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
          expect(page).to_not have_selector('#study_type_answer_access_study_info')
          expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
          expect(page).to_not have_selector('#study_type_answer_research_active')
          expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

        end
      end
      context 'change 1. to NO and 2. to NO' do

        before do

          select "No", from: 'study_type_answer_certificate_of_conf_answer'
          select "No", from: 'study_type_answer_higher_level_of_privacy_answer'
          wait_for_javascript_to_finish
          
        end

        it 'should display 1. NO and 2. NO and show 3,4,5' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'No')
          expect(page).to_not have_selector('#study_type_answer_access_study_info')
          expect(page).to have_selector('#study_type_answer_epic_inbasket')
          expect(page).to have_selector('#study_type_answer_research_active')
          expect(page).to have_selector('#study_type_answer_restrict_sending') 
          

        end
      end
      context 'change 1. to NO, 2. to YES, 2b. to NO' do

        before do

          select "No", from: 'study_type_answer_certificate_of_conf_answer'
          select "Yes", from: 'study_type_answer_higher_level_of_privacy_answer'
          select "No", from: 'study_type_answer_access_study_info_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1.NO, 2. YES, 2B. NO, ' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
          expect(page).to have_select('study_type_answer_access_study_info_answer', selected: 'No')
          expect(page).to have_selector('#study_type_answer_epic_inbasket')
          expect(page).to have_selector('#study_type_answer_research_active')
          expect(page).to have_selector('#study_type_answer_restrict_sending') 

        end
      end
      context 'change 1. to NO, 2. to YES, 2b. to YES ' do

        before do

          select "No", from: 'study_type_answer_certificate_of_conf_answer'
          select "Yes", from: 'study_type_answer_higher_level_of_privacy_answer'
          select "Yes", from: 'study_type_answer_access_study_info_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. NO, 2.YES, 2B. YES, and no other questions' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
          expect(page).to have_select('study_type_answer_access_study_info_answer'), selected: 'Yes'
          expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
          expect(page).to_not have_selector('#study_type_answer_research_active')
          expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

        end
      end
      
      context 'change 1. to NO, 2. to YES, 2b. to NO, 3 to YES, 4 to YES, 5 to YES ' do

        before do
          answer_array= ['No','Yes','No','Yes','Yes','Yes']
          select_epic_box_answers(answer_array)
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish

        end

        it 'new study type should be 7' do
          
          expect(Protocol.find(study.id).determine_study_type).to eq "7" 

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

      context 'change 1. to YES' do

        before do

          select "Yes", from: 'study_type_answer_certificate_of_conf_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. YES and show question 2' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Yes')
          expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
          expect(page).to_not have_selector('#study_type_answer_access_study_info')
          expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
          expect(page).to_not have_selector('#study_type_answer_research_active')
          expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

        end
      end
      context 'change 1. to YES, 2. to YES ' do

        before do
          answer_array= ['Yes','Yes',nil,nil,nil,nil]
          select_epic_box_answers(answer_array)
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish

        end

        it 'new study type should be 1' do
          
          expect(Protocol.find(study.id).determine_study_type).to eq "1" 

        end
      end
      context 'change 1. to NO, 2. to NO, 3. to NO, 4. to NO, 5. to NO ' do

        before do
          answer_array= ['No','No',nil,'No','No','No']
          select_epic_box_answers(answer_array)
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish

        end

        it 'new study type should be 14' do
          
          expect(Protocol.find(study.id).determine_study_type).to eq "14" 

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

      it 'should display questions 1. NO,2. YES,2b. YES ' do
        wait_for_javascript_to_finish
      
        expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
        expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
        expect(page).to have_select('study_type_answer_access_study_info_answer', selected: 'Yes')
        expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
        expect(page).to_not have_selector('#study_type_answer_research_active')
        expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
      end

      context 'change 2b to NO' do

        before do

          select "No", from: 'study_type_answer_access_study_info_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. No, 2. Yes, 2b. No and no other questions ' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
          expect(page).to have_select('study_type_answer_access_study_info_answer', selected: "No")
          expect(page).to have_selector('#study_type_answer_epic_inbasket')
          expect(page).to have_selector('#study_type_answer_research_active')
          expect(page).to have_selector('#study_type_answer_restrict_sending') 

        end
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

        expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
        expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'No')
        expect(page).to_not have_selector('#study_type_answer_access_study_info')
        expect(page).to have_select('study_type_answer_epic_inbasket_answer', selected: 'Yes')
        expect(page).to have_select('study_type_answer_research_active_answer', selected: 'Yes')
        expect(page).to have_select('study_type_answer_restrict_sending_answer', selected: 'Yes') 
      end

      context 'change 2 to YES' do

        before do

          select "Yes", from: 'study_type_answer_higher_level_of_privacy_answer'
          wait_for_javascript_to_finish

        end

        it 'should display 1. NO, 2. YES, and show 2b' do
          
          expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
          expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
          expect(page).to have_selector('#study_type_answer_access_study_info')
          expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
          expect(page).to_not have_selector('#study_type_answer_research_active')
          expect(page).to_not have_selector('#study_type_answer_restrict_sending') 

        end
      end
      context 'change 1. to NO, 2. to YES, 3. to NO, 4. to NO, 5. to YES ' do

        before do
          answer_array= ['No','Yes','No','No','No','Yes']
          select_epic_box_answers(answer_array)
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish
          find('.continue_button').click
          wait_for_javascript_to_finish

        end

        it 'new study type should be 4' do
          
          expect(Protocol.find(study.id).determine_study_type).to eq "4" 

        end
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

  QUESTIONS = ['study_type_answer_certificate_of_conf_answer', 'study_type_answer_higher_level_of_privacy_answer', 'study_type_answer_access_study_info_answer', 'study_type_answer_epic_inbasket_answer', 'study_type_answer_research_active_answer', 'study_type_answer_restrict_sending_answer']
  def select_epic_box_answers(answer_array)

    select answer_array[0], from: QUESTIONS[0] unless answer_array[0].nil?
    select answer_array[1], from: QUESTIONS[1] unless answer_array[1].nil?
    select answer_array[2], from: QUESTIONS[2] unless answer_array[2].nil?
    select answer_array[3], from: QUESTIONS[3] unless answer_array[3].nil?
    select answer_array[4], from: QUESTIONS[4] unless answer_array[4].nil?
    select answer_array[5], from: QUESTIONS[5] unless answer_array[5].nil?


  end
end