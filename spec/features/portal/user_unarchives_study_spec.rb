require 'rails_helper'

RSpec.feature 'user unarchives a study', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let(:protocol) { create(:protocol_without_validations, archived: true) }

  scenario " and sees 'Unarchive Study' button " do
    when_i_visit_the_portal_root
    and_i_view_all_studies
    then_i_should_see_an_unarchive_study_button
  end

  scenario " and hides the unarchived study " do
    when_i_visit_the_portal_root
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
    save_and_open_screenshot
    expect(page).to have_css(".protocol-archive-button[data-protocol_id='#{protocol.id}']", text: "UNARCHIVE")
  end

  def and_i_unarchive_the_study
    find(".protocol-archive-button[data-protocol_id='#{protocol.id}']").click
  end

  def then_i_should_be_able_to_archive_the_study
    expect(page).to have_css(".protocol-archive-button[data-protocol_id='#{protocol.id}']", text: "ARCHIVE")
  end
end