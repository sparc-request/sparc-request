class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations do |t|
      t.integer :protocol_id
      t.boolean :cancer_center
      t.boolean :oral_health_cobre
      t.boolean :reach
      t.boolean :lipidomics_cobre
      t.boolean :cardiovascular_cobre
      t.boolean :inbre
      t.boolean :cchp

      t.timestamps
    end

    add_index :affiliations, :protocol_id
  end
end
