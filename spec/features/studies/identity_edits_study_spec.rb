require 'rails_helper'

RSpec.describe "Identity edits Study", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request
  build_study

  scenario "and edits the short title" do
    visit protocol_service_request_path service_request.id
    find('.edit-study').click

    select "Funded", from: "study_funding_status"
    select "Federal", from: "study_funding_source"
    fill_in "study_short_title", with: "Bob"
    find('.continue_button').click
    wait_for_javascript_to_finish
    click_link 'Continue'
    wait_for_javascript_to_finish

    expect(Study.first.short_title).to eq('Bob')
  end

  scenario 'and sets epic access' do
    study.update_attribute(:selected_for_epic, true)
    stub_const("USE_EPIC", true)

    visit protocol_service_request_path service_request.id
    find('.edit-study').click
    wait_for_javascript_to_finish

    find("#study_type_answer_certificate_of_conf_answer").set(false)
    find("#study_type_answer_certificate_of_conf_answer").trigger('change')

    find('#study_type_answer_higher_level_of_privacy_answer').set(true)
    find('#study_type_answer_higher_level_of_privacy_answer').trigger('change')

    find('#study_type_answer_epic_inbasket_answer').set(false)
    find('#study_type_answer_epic_inbasket_answer').trigger('change')

    find('#study_type_answer_research_active_answer').set(false)
    find('#study_type_answer_research_active_answer').trigger('change')

    find('#study_type_answer_restrict_sending_answer').set(false)
    find('#study_type_answer_restrict_sending_answer').trigger('change')

    expect(page).to have_css('.continue_button')
    find('.continue_button').click
    wait_for_javascript_to_finish

    expect(find("#study_project_roles_attributes_#{jpl6.id}_epic_access_false")).to be_checked
  end
end
