class CreateEpicQueues < ActiveRecord::Migration
  def change
    create_table :epic_queues do |t|
      t.belongs_to :protocol
      t.timestamps
    end
  end
end
