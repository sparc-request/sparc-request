require 'spec_helper'

describe "admin portal notifications", :js => true do
  let_there_be_lane
  fake_login_for_each_test
  build_service_request_with_project
  build_fake_notification
  let!(:first_reply) {FactoryGirl.create(:message, notification_id: notification.id, to: sender.id, from: jug2.id, email: "test2@test.org", subject: "Test Reply", body: "This is a test, and only a test")}
  let!(:project_role) {FactoryGirl.create(:project_role, protocol_id: service_request.protocol.id, identity_id: sender.id, project_rights: "approve", role: "co-investigator")}


  before :each do
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
  end

  it "should allow user to create new message" do
    find("li.new_notification[data-identity_id='#{sender.id}']").click
    wait_for_javascript_to_finish
    page.fill_in "message_subject", :with => "Test Subject"
    page.fill_in "message_body", :with => "Test Body"
    within "div.ui-dialog-buttonpane", :visible => true do
      click_button("Submit")
    end
    wait_for_javascript_to_finish
    Message.find_by_subject("Test Subject").body.should eq("Test Body")
  end

  describe "viewing and replying" do
    it "when viewing a message" do
      find("a.notifications-tab").click
      find("td.subject_column").click
      wait_for_javascript_to_finish
      find("div.shown-message-body").should be_visible
    end

    it "when replying to a message" do
      find("a.notifications-tab").click
      find("td.subject_column").click
      wait_for_javascript_to_finish
      page.fill_in 'message[body]', :with => "Test Reply II, Reply to Reply"
      within "div.ui-dialog-buttonpane", :visible => true do
        click_button("Submit")
      end
      wait_for_javascript_to_finish
      find("td.body_column").text.should eq("Test Reply II, Reply to Reply")
    end
  end

end