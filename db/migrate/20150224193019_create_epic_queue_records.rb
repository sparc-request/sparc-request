class CreateEpicQueueRecords < ActiveRecord::Migration
  def change
    create_table :epic_queue_records do |t|
      t.integer :protocol_id
      t.string :status

      t.timestamps
    end
  end
end
