class TransferReadFromMessagesToUserNotifications < ActiveRecord::Migration
  remove_column :messages, :read
  add_column :user_notifications, :read, :boolean
end
