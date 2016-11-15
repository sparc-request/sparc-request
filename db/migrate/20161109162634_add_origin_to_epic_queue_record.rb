class AddOriginToEpicQueueRecord < ActiveRecord::Migration
  def change
    add_column :epic_queue_records, :origin, :string
    add_column :epic_queue_records, :identity_id, :integer
  end
end
