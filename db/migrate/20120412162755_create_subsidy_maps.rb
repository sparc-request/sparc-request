class CreateSubsidyMaps < ActiveRecord::Migration
  def change
    create_table :subsidy_maps do |t|
      t.integer :organization_id
      t.decimal :max_dollar_cap, :precision => 12, :scale => 4
      t.decimal :max_percentage, :precision => 5, :scale => 2

      t.timestamps
    end

    add_index :subsidy_maps, :organization_id
  end
end
