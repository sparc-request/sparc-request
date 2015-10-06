require 'rails_helper'

RSpec.feature 'user views active studies', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before(:each) do
    project.update_attributes(archived: true)
  end

  scenario "and sees 'Show Active Projects/Studies' link " do
    when_i_visit_the_portal_root
    and_i_view_all_the_studies
    then_i_should_see_a_link_to_active_studies
  end

  scenario "and sees active studies after click 'Show Active Projects/Studies' link " do
    when_i_visit_the_portal_root
    and_i_view_all_the_studies
    and_then_i_view_the_active_studies
    then_i_should_see_only_active_studies
  end

  def when_i_visit_the_portal_root
    visit portal_root_path
    wait_for_javascript_to_finish
  end

  def and_i_view_all_the_studies
  	find('.archive_button').click
  end

  def then_i_should_see_a_link_to_active_studies
    expect(page).to have_css(".archive_button", text: "Show Active Projects/Studies")
  end

  def and_then_i_view_the_active_studies
    find('.archive_button').click
  end

  def then_i_should_see_only_active_studies
    expect(page).to_not have_css(".protocol-archive-button[data-protocol_id='#{project.id}']", text: "UNARCHIVE")
  end
end
