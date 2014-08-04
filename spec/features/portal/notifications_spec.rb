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
      wait_for_javascript_to_finish
      find(".new-portal-notification-button").click
      wait_for_javascript_to_finish
      sleep 3
      first(".new_notification").click
      wait_for_javascript_to_finish
      page.should have_text("You can not send a message to yourself.")
    end
  end

end
