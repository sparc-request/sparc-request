require 'rails_helper'

RSpec.describe "Identity creates Study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    service_request.update_attribute(:status, 'first_draft')
    visit protocol_service_request_path service_request.id
    visit '/'
    click_link 'South Carolina Clinical and Translational Institute (SCTR)'
    wait_for_javascript_to_finish
    click_link 'Office of Biomedical Informatics'
    wait_for_javascript_to_finish
    click_button 'Add', match: :first
    wait_for_javascript_to_finish
    click_button 'Yes'
    wait_for_javascript_to_finish
    find('.submit-request-button').click
    click_link 'New Research Study'
    wait_for_javascript_to_finish
    find('#study_selected_for_epic_true').click()

  end

  context 'study type 0' do

    before :each do
      answer_array= ['No','No',nil,'Yes','No','No']
      select_epic_box_answers(answer_array)
    end

    it 'should display active questions 1,2,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')        
    end 
  end

  context 'study type 1' do

    before :each do
      answer_array= ['Yes',nil,nil,nil,nil,nil]
      select_epic_box_answers(answer_array)
    end

    it 'should display active questions 1,2' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to_not have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
      expect(page).to_not have_selector('#study_type_answer_research_active')
      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
    end
  end

  context 'study type 2' do

     before :each do
      answer_array= ['No','Yes','Yes',nil,nil,nil]
      select_epic_box_answers(answer_array)
    end

    it 'should display active questions 1,2,2b' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
      expect(page).to_not have_selector('#study_type_answer_research_active')
      expect(page).to_not have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 3' do

    before :each do
      answer_array= ['No','Yes','No','No','Yes','Yes']
      select_epic_box_answers(answer_array)
    end

    it "should display active questions 1,2,2b,3,4,5" do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
  end
  context 'study type 4' do

    before :each do
      answer_array= ['No','Yes','No','No','No','Yes']
      select_epic_box_answers(answer_array)
    end

    it 'should display active questions 1,2,2b,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 5' do

    before :each do
      answer_array= ['No','Yes','No','No','Yes','No']
      select_epic_box_answers(answer_array)
    end

    it 'should display active questions 1,2,2b,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 6' do

    before :each do
      answer_array= ['No','Yes','No','No','No','No']
      select_epic_box_answers(answer_array)
    end

    it 'should display active questions 1,2,2b,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 7' do
    before :each do
      answer_array= ['No','Yes','No','Yes','Yes','Yes']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,2b,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 8' do
    before :each do
      answer_array= ['No','Yes','No','Yes','No','Yes']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,2b,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 9' do
    before :each do
      answer_array= ['No','Yes','No','Yes','Yes','No']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,2b,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 10' do
    before :each do
      answer_array= ['No','Yes','No','Yes','No','No']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,2b,3,4,5' do
      wait_for_javascript_to_finish
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 11' do
    before :each do
      answer_array= ['No','No',nil,'No','Yes','Yes']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 12' do
    before :each do

      answer_array= ['No','No',nil,'No','No','Yes']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do

      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 13' do
    before :each do
      answer_array= ['No','No',nil,'No','Yes','No']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 14' do
    before :each do
      answer_array= ['No','No',nil,'No','No','No']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do
      wait_for_javascript_to_finish
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 15' do
    before :each do
      answer_array= ['No','No',nil,'Yes','Yes','Yes']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end
  context 'study type 16' do
    before :each do
      answer_array= ['No','No',nil,'Yes','No','Yes']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
    
  end

  context 'study type 17' do
    before :each do
      answer_array= ['No','No',nil,'Yes','Yes','No']
      select_epic_box_answers(answer_array)
    end
    it 'should display active questions 1,2,3,4,5' do
      expect(page).to have_selector('#study_type_answer_certificate_of_conf')
      expect(page).to have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_selector('#study_type_answer_epic_inbasket')
      expect(page).to have_selector('#study_type_answer_research_active')
      expect(page).to have_selector('#study_type_answer_restrict_sending')
    end
  end

  def select_epic_box_answers(answer_array)
    questions = ['study_type_answer_certificate_of_conf_answer', 'study_type_answer_higher_level_of_privacy_answer', 'study_type_answer_access_study_info_answer', 'study_type_answer_epic_inbasket_answer', 'study_type_answer_research_active_answer', 'study_type_answer_restrict_sending_answer']
    select answer_array[0], from: questions[0] unless answer_array[0].nil?
    select answer_array[1], from: questions[1] unless answer_array[1].nil?
    select answer_array[2], from: questions[2] unless answer_array[2].nil?
    select answer_array[3], from: questions[3] unless answer_array[3].nil?
    select answer_array[4], from: questions[4] unless answer_array[4].nil?
    select answer_array[5], from: questions[5] unless answer_array[5].nil?


  end
end