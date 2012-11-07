class AddTimestampsToUserNotifications < ActiveRecord::Migration
  def change
    change_table :user_notifications do |t|
      t.timestamps
    end
  end
end
