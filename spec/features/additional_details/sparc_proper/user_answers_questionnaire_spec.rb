require 'rails_helper'

RSpec.describe 'User has a questionnaire to complete', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    institution    = create(:institution, name: "Institution")
    provider       = create(:provider, name: "Provider", parent: institution)
    program        = create(:program, name: "Program", parent: provider, process_ssrs: true)
    service        = create(:service_with_pricing_map, name: 'Brain Removal')
    @protocol      = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr            = create(:service_request_without_validations, status: 'first_draft', protocol: @protocol)
    ssr            = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                     create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
                     create(:arm, protocol: @protocol, visit_count: 1)
    questionnaire  = create(:questionnaire, :without_validations, service: service, name: 'Does your brain hurt?')
    item           = create(:item, questionnaire: questionnaire, content: 'How is your brain? Does it hurt and need to be removed?', item_type: 'yes_no')
    item2          = create(:item, questionnaire: questionnaire, content: 'Emails make me feel sassy', item_type: 'email')
    item3          = create(:item, questionnaire: questionnaire, content: "Oh, I'll get you a toe, dude", item_type: 'phone')
    visit document_management_service_request_path(@sr)
    wait_for_javascript_to_finish
  end

  describe 'user visits the documents page' do

    it 'should see the questionnaire' do
      within '.document-management-submissions' do
        expect(page).to have_content('Brain Removal')
      end
    end

    before :each do
      click_link 'Complete Form'
      wait_for_javascript_to_finish
    end

    it 'should be able to see the submission modal' do
      expect(page).to have_content('Questionnaire Submission')
    end 

    it 'should be able to answer questionnaire and create a submission' do
      choose 'Yes'
      click_link 'Create Submission'
      wait_for_javascript_to_finish
      expect(page).to have_css('#submissionModal .modal-body form')
    end 

    it 'should validate email format' do
      find('#submission_questionnaire_responses_attributes_1_content').set('crazy pills')
      sleep 1
      click_link 'Create Submission'
      expect(page).to have_content('Error')
    end

    it 'should validate phone format' do
      find('#submission_questionnaire_responses_attributes_1_content').set('This is a not a phone number')
      sleep 1
      click_link 'Create Submission'
      expect(page).to have_content('Error')
    end
  end
end
