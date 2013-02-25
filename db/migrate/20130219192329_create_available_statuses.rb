class CreateAvailableStatuses < ActiveRecord::Migration
  def change
    create_table :available_statuses do |t|
      t.integer :organization_id
      t.string :status

      t.timestamps
    end

    add_index :available_statuses, :organization_id
  end
end
