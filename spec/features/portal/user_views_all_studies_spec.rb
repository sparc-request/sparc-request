require 'rails_helper'

RSpec.feature 'user views all studies', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    create(:protocol_without_validations, archived: true)
  end

  scenario "and sees 'Show All Studies' link " do
    when_i_visit_the_portal_root
    then_i_should_see_a_link_to_all_studies
  end

  scenario "and sees all studies after click 'Show All Studies' link " do
    when_i_visit_the_portal_root
    and_i_view_all_studies
    then_i_should_see_all_studies
  end

  def when_i_visit_the_portal_root
    visit portal_root_path
  end

  def then_i_should_see_a_link_to_all_studies
    expect(page).to have_css(".archive_button", text: "Show All Studies")
  end

  def and_i_view_all_studies
    find('.archive_button').click
  end

  def then_i_should_see_all_studies
    expect(page).to have_css(".blue-provider")
    expect(page).to have_css(".protocol-information")
  end
end