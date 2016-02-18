require 'rails_helper'
# require 'support/pages/dashboard/notes/index_modal'
# require 'support/pages/dashboard/notes/new_modal'

module Dashboard
  module Notifications
    class IndexPage < SitePrism::Page
      set_url '/dashboard/notifications'

      element :mark_as_read_button, 'button', text: 'Mark as Read'
      element :mark_as_unread_button, 'button', text: 'Mark as Unread'

      element :search_field, "input[placeholder='Search']"

      element :view_inbox_button, 'button', text: 'Inbox'
      element :view_sent_button, 'button', text: 'Sent'

      section :notifications_table, '.protocol-management-and-financial-view' do
        element :select_all, 'input[name="btSelectAll"]'
        element :user_header, 'th', text: 'User'
        element :time_header, 'th', text: 'Time'
        elements :notification_rows, 'tbody tr'
        sections :notifications, 'tbody tr' do
          element :select_checkbox, 'input[name="btSelectItem"]'
        end
      end
    end
  end
end
