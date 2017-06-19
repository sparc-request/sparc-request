class AddAttemptedPushToEpicQueues < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :epic_queues, :attempted_push, :boolean, default: false
  end
end
