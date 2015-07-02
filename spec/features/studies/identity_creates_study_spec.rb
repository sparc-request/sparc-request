require 'rails_helper'

RSpec.feature 'Identity creates Study', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study()

  before :each do
    build_study_type_questions
    service_request.update_attribute(:status, 'first_draft')
    visit protocol_service_request_path service_request.id
    expect(page).to have_css('.new-study')
    click_link 'New Study'
  end

  scenario 'with invalid form data' do
    find('.continue_button').click
    expect(page).to have_content("Short title can't be blank")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Funding status can't be blank")
    expect(page).to have_content("Sponsor name can't be blank")
  end

  scenario 'with valid form data' do
    fill_in 'study_short_title', with: 'Bob'
    fill_in 'study_title', with: 'Dole'
    choose 'study_has_cofc_true'
    fill_in 'study_sponsor_name', with: "Captain Kurt 'Hotdog' Zanzibar"
    select 'Funded', from: 'study_funding_status'
    select 'Federal', from: 'study_funding_source'

    find('.continue_button').click

    select 'Primary PI', from: 'project_role_role'
    click_button 'Add Authorized User'
    sleep 1

    fill_autocomplete 'user_search_term', with: 'bjk7'
    page.find('a', text: 'Brian Kelsey (kelsey@musc.edu)', visible: true).click()
    select 'Billing/Business Manager', from: 'project_role_role'
    click_button 'Add Authorized User'

    find('.continue_button').click

    expect(find('.edit_study_id')).to have_value Protocol.last.id.to_s
  end
end
