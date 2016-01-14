require 'rails_helper'

RSpec.describe "Identity creates Study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    service_request.update_attribute(:status, 'first_draft')
    visit protocol_service_request_path service_request.id
    expect(page).to have_css('.new-study')
    click_link "New Study"
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
  context 'submitting form with incomplete fields' do
    before :each do
      answer_array= ['Yes',nil,nil,nil,nil,nil]
      select_epic_box_answers(answer_array)
    end

    it 'should throw an error when trying to submit incomplete epic box info' do
      select 'Select One', from: 'study_type_answer_certificate_of_conf_answer'
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'Select One')
      expect(page).to have_css('#study_type_answer_certificate_of_conf_answer.visual_error')
      expect(page).to_not have_selector('#study_type_answer_higher_level_of_privacy')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
      expect(page).to_not have_selector('#study_type_answer_research_active')
      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
    end

    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','Select One',nil,nil,nil,nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Select One')
      expect(page).to have_css('#study_type_answer_higher_level_of_privacy_answer.visual_error')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
      expect(page).to_not have_selector('#study_type_answer_research_active')
      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
    end

    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','Yes','Select One',nil,nil,nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
      expect(page).to have_select('study_type_answer_access_study_info_answer', selected: 'Select One')
      expect(page).to have_css('#study_type_answer_access_study_info_answer.visual_error')
      expect(page).to_not have_selector('#study_type_answer_epic_inbasket')
      expect(page).to_not have_selector('#study_type_answer_research_active')
      expect(page).to_not have_selector('#study_type_answer_restrict_sending') 
    end

    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','Yes','No',nil,nil,nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
      expect(page).to have_select('study_type_answer_access_study_info_answer', selected: 'No')
      expect(page).to have_css('#study_type_answer_epic_inbasket_answer.visual_error')
      expect(page).to have_css('#study_type_answer_research_active_answer.visual_error')
      expect(page).to have_css('#study_type_answer_restrict_sending_answer.visual_error')
    end

    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','Yes','No','Yes',nil,nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
      expect(page).to have_select('study_type_answer_access_study_info_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_epic_inbasket_answer', selected: 'Yes')
      expect(page).to have_css('#study_type_answer_research_active_answer.visual_error')
      expect(page).to have_css('#study_type_answer_restrict_sending_answer.visual_error')
    end

    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','Yes','No','Yes','Yes',nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'Yes')
      expect(page).to have_select('study_type_answer_access_study_info_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_epic_inbasket_answer', selected: 'Yes')
      expect(page).to have_select('study_type_answer_research_active_answer', selected: 'Yes')
      expect(page).to have_css('#study_type_answer_restrict_sending_answer.visual_error')
    end
    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','No',nil,nil,nil,nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'No')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_css('#study_type_answer_epic_inbasket_answer.visual_error')
      expect(page).to have_css('#study_type_answer_research_active_answer.visual_error')
      expect(page).to have_css('#study_type_answer_restrict_sending_answer.visual_error')
    end
    it 'should throw an error when trying to submit incomplete epic box info' do
      answer_array= ['No','No',nil,'Yes',nil,nil]
      select_epic_box_answers(answer_array)
      find('.continue_button').click
      expect(page).to have_content("Study type questions must be selected")
      expect(page).to have_select('study_type_answer_certificate_of_conf_answer', selected: 'No')
      expect(page).to have_select('study_type_answer_higher_level_of_privacy_answer', selected: 'No')
      expect(page).to_not have_selector('#study_type_answer_access_study_info')
      expect(page).to have_select('study_type_answer_epic_inbasket_answer', selected: 'Yes')
      expect(page).to have_css('#study_type_answer_research_active_answer.visual_error')
      expect(page).to have_css('#study_type_answer_restrict_sending_answer.visual_error')
    end
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