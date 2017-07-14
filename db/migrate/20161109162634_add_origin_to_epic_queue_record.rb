class AddOriginToEpicQueueRecord < ActiveRecord::Migration[4.2]
  def change
    add_column(:epic_queue_records, :origin, :string)
    add_reference(:epic_queue_records, :identity)
  end
end
