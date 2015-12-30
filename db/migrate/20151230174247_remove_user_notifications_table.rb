class RemoveUserNotificationsTable < ActiveRecord::Migration

  def self.up
    add_column :messages, :read, :boolean

    Notification.all.each do |notification|
      user_notifications = notification.user_notifications
      identity_hash = user_notifications.group_by{ |un| un.identity_id }
      identity_hash.each do |id, id_uns|
        messages_to_id = notification.messages.where("`to` = #{id}")
        if id_uns.all?{ |unote| unote.read }
          messages_to_id.update_all(read: 1)
        else
          messages_to_id.update_all(read: 0)
        end
      end
    end

    drop_table :user_notifications
  end

  def self.down

    create_table :user_notifications do |t|
      t.integer :identity_id
      t.integer :notification_id
      t.boolean :read
      t.timestamps
    end

    Notification.all.each do |notification|
      messages = notification.messages
      identity_hash = messages.group_by{ |m| m.to }
      identity_hash.each do |id, id_mes|
        if id_mes.any? { |m| !m.read }
          UserNotification.create(identity_id: id, notification_id: notification.id, read: 0)
        else
          UserNotification.create(identity_id: id, notification_id: notification.id, read: 1)
        end
      end
    end

    remove_column :messages, :read, :boolean
  end

end
