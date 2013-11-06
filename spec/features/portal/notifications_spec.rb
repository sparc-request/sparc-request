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

  describe "sending a new notification" do

    before :each do
      visit portal_root_path
    end

    it "should open up the dialog box" do
      find(".new-portal-notification-button").click
      first(".new_notification").click
      wait_for_javascript_to_finish
      page.should have_text("You can not send a message to yourself.")
    end
  end

end
