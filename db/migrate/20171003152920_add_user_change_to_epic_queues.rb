class AddUserChangeToEpicQueues < ActiveRecord::Migration[5.1]
  def change
    add_column :epic_queues, :user_change, :boolean, default: false
  end
end
