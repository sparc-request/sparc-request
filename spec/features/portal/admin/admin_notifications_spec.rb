# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'spec_helper'

describe "admin portal notifications", :js => true do
  let_there_be_lane
  let_there_be_j
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
      click_button("Send")
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
      find("td.body_column").should have_exact_text("Test Reply II, Reply to Reply")
    end
  end

end
