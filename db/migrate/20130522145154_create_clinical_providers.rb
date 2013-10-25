class CreateClinicalProviders < ActiveRecord::Migration
  def change
    create_table :clinical_providers do |t|
      t.integer :identity_id
      t.integer :organization_id

      t.timestamps
    end

  add_index :clinical_providers, :organization_id
  end
end
