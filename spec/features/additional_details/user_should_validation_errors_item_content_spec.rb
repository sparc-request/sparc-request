require 'rails_helper'

RSpec.describe 'User should see validation errors on item content', js: true do
  let_there_be_lane
  fake_login_for_each_test

  scenario 'successfully' do
    service = create(:service, :with_ctrc_organization)
    visit new_service_additional_details_questionnaire_path(service)
    fill_in 'questionnaire_name', with: 'New Questionnaire'
    fill_in 'questionnaire_items_attributes_0_content', with: 'What is your favorite color?'
    select 'Radio Button', from: 'questionnaire_items_attributes_0_item_type'

    check 'questionnaire_items_attributes_0_required'

    click_button 'Create Questionnaire'

    expect(page).to have_content "Content can't be blank"
  end

  scenario 'successfully' do
    service = create(:service, :with_ctrc_organization)
    visit new_service_additional_details_questionnaire_path(service)
    fill_in 'questionnaire_name', with: 'New Questionnaire'
    fill_in 'questionnaire_items_attributes_0_content', with: 'What is your favorite color?'
    select 'Radio Button', from: 'questionnaire_items_attributes_0_item_type'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_0_content', with: 'Green'
    click_link 'Add another Option'

    check 'questionnaire_items_attributes_0_required'

    click_button 'Create Questionnaire'

    expect(page).to have_content "Content can't be blank"
  end

  scenario 'successfully' do
    service = create(:service, :with_ctrc_organization)
    visit new_service_additional_details_questionnaire_path(service)
    fill_in 'questionnaire_name', with: 'New Questionnaire'
    fill_in 'questionnaire_items_attributes_0_content', with: 'What is your favorite color?'
    select 'Radio Button', from: 'questionnaire_items_attributes_0_item_type'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_0_content', with: 'Green'
    click_link 'Add another Option'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_1_content', with: 'Red'

    check 'questionnaire_items_attributes_0_required'

    click_button 'Create Questionnaire'

    expect(page).not_to have_content "Content can't be blank"
    expect(current_path).to eq service_additional_details_questionnaires_path(service)
    expect(Questionnaire.count).to eq 1
  end
end

