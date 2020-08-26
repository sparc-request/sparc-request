class AddSharedToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :shared, :boolean
  end
end
