# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

module Dashboard
  module Notifications
    class IndexPage < SitePrism::Page
      set_url '/dashboard/notifications'

      element :compose_button, 'button', text: 'Compose Message'

      # modal that appears after clicking the Compose button
      section :send_notification_modal, '.modal', text: "Send Notification" do
        # element :select_user, :field, "Select User:"        -- label not associated correctly
        element :select_user, "input[placeholder='Search for a User']"
        elements :search_results, ".tt-selectable"
        element :subject_line, "input[placeholder='Subject']"
        element :message_box, "textarea[placeholder='Please enter message text here...']"
        element :send_button, "button", text: "Send"
      end

      element :mark_as_read_button, 'button', text: 'Mark as Read'
      element :mark_as_unread_button, 'button', text: 'Mark as Unread'

      element :search_field, "input[placeholder='Search']"

      element :view_inbox_button, 'button', text: 'Inbox'
      element :view_sent_button, 'button', text: 'Sent'

      # checkbox that selects every message
      element :select_all, 'input[name="btSelectAll"]'

      # User name column of table
      element :user_header, 'th', text: 'User'

      # Time column of table
      element :time_header, 'th', text: 'Time'

      # List of messages
      sections :notifications, 'tbody tr' do
        element :select_checkbox, 'input[name="btSelectItem"]'

        # matches only checked
        element :checked_select_checkbox, 'input[name="btSelectItem"]:checked'

        # matches only unchecked
        element :unchecked_select_checkbox, 'input[name="btSelectItem"]:not(:checked)'
      end
    end
  end
end
