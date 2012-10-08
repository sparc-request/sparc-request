class CreateImpactAreas < ActiveRecord::Migration
  def change
    create_table :impact_areas do |t|
      t.integer :protocol_id
      t.string  :name

      t.timestamps
    end

    add_index :impact_areas, :protocol_id
  end
end
