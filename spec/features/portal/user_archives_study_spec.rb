require 'rails_helper'

RSpec.feature 'user archives a study', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  let(:protocol_id) { Protocol.first.id }

  scenario " and sees 'Archive Study' button " do
    when_i_visit_the_portal_root
    then_i_should_see_an_archive_study_button
  end

  scenario " and hides the archived study " do
    when_i_visit_the_portal_root
    and_i_archive_the_study
    then_i_should_not_see_the_archived_study
  end

  def when_i_visit_the_portal_root
    visit portal_root_path
    wait_for_javascript_to_finish
  end

  def then_i_should_see_an_archive_study_button
    expect(page).to have_css(".protocol-archive-button[data-protocol_id='#{protocol_id}']", text: "ARCHIVE")
  end

  def and_i_archive_the_study
    find(".protocol-archive-button[data-protocol_id='#{protocol_id}']").click
  end

  def then_i_should_not_see_the_archived_study
    expect(page).to_not have_css("#blue-provider-#{protocol_id}")
    expect(page).to_not have_css(".protocol-information-#{protocol_id}")
  end
end