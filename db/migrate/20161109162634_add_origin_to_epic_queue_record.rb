class AddOriginToEpicQueueRecord < ActiveRecord::Migration[5.1]
  def change
    add_column(:epic_queue_records, :origin, :string)
    add_reference(:epic_queue_records, :identity)
  end
end
