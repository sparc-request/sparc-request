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
  end

  scenario ''
end