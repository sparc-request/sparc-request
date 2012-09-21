class CreateImpactAreas < ActiveRecord::Migration
  def change
    create_table :impact_areas do |t|
      t.integer :protocol_id
      t.boolean :hiv_aids
      t.boolean :pediatrics
      t.boolean :stroke
      t.boolean :diabetes
      t.boolean :hypertension
      t.boolean :cancer

      t.timestamps
    end

    add_index :impact_areas, :protocol_id
  end
end
