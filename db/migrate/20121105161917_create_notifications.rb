class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :sub_service_request_id
      t.integer :originator_id

      t.timestamps
    end
  end
end
