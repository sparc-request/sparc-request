require 'rails_helper'

RSpec.feature 'user unarchives a study', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before(:each) do
    project.update_attributes(archived: true)
    when_i_visit_the_portal_root
  end

  scenario " and sees 'Unarchive Study' button " do 
    and_i_view_all_studies
    then_i_should_see_an_unarchive_study_button
  end

  scenario " and hides the unarchived study " do
    and_i_view_all_studies
    and_i_unarchive_the_study
    then_i_should_be_able_to_archive_the_study
  end

  def when_i_visit_the_portal_root
    visit portal_root_path
    wait_for_javascript_to_finish
  end

  def and_i_view_all_studies
    find('.archive_button').click
    wait_for_javascript_to_finish
  end

  def then_i_should_see_an_unarchive_study_button
    expect(page).to have_css(".protocol-archive-button[data-protocol_id='#{project.id}']", text: "UNARCHIVE")
  end

  def and_i_unarchive_the_study
    find(".protocol-archive-button[data-protocol_id='#{project.id}']").click
  end

  def then_i_should_be_able_to_archive_the_study
    expect(page).to have_css(".protocol-archive-button[data-protocol_id='#{project.id}']", text: "ARCHIVE")
  end
end
