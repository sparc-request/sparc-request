class CreateServiceProviders < ActiveRecord::Migration
  def change
    create_table :service_providers do |t|
      t.integer :identity_id
      t.integer :organization_id
      t.integer :service_id
      t.boolean :is_primary_contact

      t.timestamps
    end

    add_index :service_providers, :organization_id
    add_index :service_providers, :service_id
  end
end
