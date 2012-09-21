class CreateCatalogManagers < ActiveRecord::Migration
  def change
    create_table :catalog_managers do |t|
      t.integer :identity_id
      t.integer :organization_id

      t.timestamps
    end

    add_index :catalog_managers, :organization_id
    add_index :catalog_managers, :identity_id
  end
end
