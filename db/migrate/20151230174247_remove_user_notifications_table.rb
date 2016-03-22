class RemoveUserNotificationsTable < ActiveRecord::Migration

  class UserNotification < ActiveRecord::Base
  end

  def self.up

    add_column :notifications, :subject, :string
    add_column :notifications, :other_user_id, :integer
    add_column :notifications, :read_by_originator, :boolean
    add_column :notifications, :read_by_other_user, :boolean

    Notification.all.each do |notification|
      messages = notification.messages
      unless messages.empty?
        last_message = messages.last
        notification.update_column(:subject, last_message.subject)

        other_user_id = ([last_message.to, last_message.from] - [notification.originator_id]).first
        notification.update_column(:other_user_id, other_user_id)
      end

      orig_user_notifications = UserNotification.where(identity_id: notification.originator_id, notification_id: notification.id)
      unless orig_user_notifications.empty?
        orig_user_notification = orig_user_notifications.first
        notification.update_column(:read_by_originator, orig_user_notification.read)
      end

      other_user_notifications = UserNotification.where(identity_id: notification.other_user_id, notification_id: notification.id)
      unless other_user_notifications.empty?
        other_user_notification = other_user_notifications.first
        notification.update_column(:read_by_other_user, other_user_notification.read)
      end
    end

    remove_column :messages, :subject, :string
    drop_table :user_notifications
  end

  def self.down

    create_table :user_notifications do |t|
      t.integer :identity_id
      t.integer :notification_id
      t.boolean :read
      t.timestamps
    end

    add_column :messages, :subject, :string

    Notification.all.each do |notification|
      UserNotification.create(identity_id: notification.originator_id, notification_id: notification.id, read: notification.read_by_originator)
      UserNotification.create(identity_id: notification.other_user_id, notification_id: notification.id, read: notification.read_by_other_user)

      unless notification.messages.empty?
        notification.messages.update_all(subject: notification.subject)
      end
    end

    remove_column :notifications, :read_by_originator, :boolean
    remove_column :notifications, :read_by_other_user, :boolean
    remove_column :notifications, :other_user_id, :integer
    remove_column :notifications, :subject, :string
  end

end
