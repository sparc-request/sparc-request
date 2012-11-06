class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.integer :identity_id
      t.integer :notification_id
    end
  end
end
