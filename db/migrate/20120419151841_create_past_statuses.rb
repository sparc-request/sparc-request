class CreatePastStatuses < ActiveRecord::Migration
  def change
    create_table :past_statuses do |t|
      t.integer :sub_service_request_id
      t.string :status
      t.datetime :date

      t.timestamps
    end

    add_index :past_statuses, :sub_service_request_id
  end
end
