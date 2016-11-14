class AddOriginToEpicQueueRecord < ActiveRecord::Migration
  def change
    add_column :epic_queue_records, :origin, :string
  end
end
