class CreateDashboardFilters < ActiveRecord::Migration
  def change
    create_table :protocol_filters do |t|
      t.integer :identity_id
      t.string :search_name
      t.boolean :show_archived
      t.integer :for_admin
      t.integer :for_identity_id
      t.string :search_query
      t.integer :with_core
      t.string :with_status
      t.timestamps
    end
  end
end
