require 'rails_helper'

RSpec.feature 'Identity edits Study', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request
  build_study

  before :each do
    Protocol.first.update_attribute :has_cofc, false
    visit protocol_service_request_path service_request.id
    find('.edit-study').click
    wait_for_javascript_to_finish
  end

  scenario 'and edits the short title' do
    select 'Funded', from: 'study_funding_status'
    select 'Federal', from: 'study_funding_source'
    fill_in 'study_short_title', with: 'Bob'
    find('.continue_button').click
    wait_for_javascript_to_finish
    find('.continue_button').click
    wait_for_javascript_to_finish
    find('.edit-study').click

    expect(find('#study_short_title')).to have_value('Bob')
  end

  scenario 'and sets epic access' do
    find('.continue_button').click

    expect(find('#study_project_roles_attributes_#{jpl6.id}_epic_access_false')).to be_checked
  end
end
