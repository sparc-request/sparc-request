require 'spec_helper'

describe "notifications page", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project
  build_fake_notification

  before :each do
    add_visits
    visit portal_notifications_path
  end

  it "should have an unread notification" do
    page.should have_css("tr.notification_row.unread")
  end

  it "should allow user to view unread message" do
    find("td.subject_column").click
    wait_for_javascript_to_finish
    find("div.shown-message-body").should be_visible
  end

  it "should allow user to reply to a message" do
    find("td.subject_column").click
    wait_for_javascript_to_finish
    page.fill_in 'message[body]', :with => "Test Reply"
    click_button("Submit")
    wait_for_javascript_to_finish
    find("td.body_column").should have_text("Test Reply")
  end

end
