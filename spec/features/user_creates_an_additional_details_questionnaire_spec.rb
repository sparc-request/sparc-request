require 'rails_helper'

RSpec.describe 'User creates an additional details questionnaire', js: true do
  let_there_be_lane
  scenario 'successfully' do
    service = create(:service)
    visit new_service_additional_details_questionnaire_path(service)
    fill_in 'questionnaire_name', with: 'New Questionnaire'
    fill_in 'questionnaire_items_attributes_0_content', with: 'What is your favorite color?'
    select 'Radio Button', from: 'questionnaire_items_attributes_0_item_type'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_0_content', with: 'Green'
    click_link 'Add another Option'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_1_content', with: 'Red'

    check 'questionnaire_items_attributes_0_required'

    click_button 'Create Questionnaire'

    expect(current_path).to eq service_additional_details_questionnaires_path(service)
    expect(Questionnaire.count).to eq 1
    expect(Item.count).to eq 1
    expect(ItemOption.count).to eq 2
  end
end
