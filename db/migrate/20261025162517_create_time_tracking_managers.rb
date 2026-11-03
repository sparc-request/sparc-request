class CreateTimeTrackingManagers < ActiveRecord::Migration[7.0]
  def change
    create_table :time_tracking_managers do |t|
      t.references :identity
      t.references :organization

      t.timestamps
    end

    add_index :time_tracking_managers, [:identity_id, :organization_id], unique: true
  end
end
