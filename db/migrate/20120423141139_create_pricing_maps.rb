class CreatePricingMaps < ActiveRecord::Migration
  def change
    create_table :pricing_maps do |t|
      t.integer :service_id
      t.string :unit_type
      t.decimal :unit_factor, :precision => 5, :scale => 2
      t.decimal :percent_of_fee, :precision => 5, :scale => 2
      t.boolean :is_one_time_fee
      t.decimal :full_rate, :precision => 12, :scale => 4
      t.boolean :exclude_from_indirect_cost
      t.integer :unit_minimum
      t.decimal :non_corporate_rate, :precision => 12, :scale => 4
      t.decimal :corporate_rate, :precision => 12, :scale => 4
      t.decimal :research_rate, :precision => 12, :scale => 4
      t.datetime :effective_date

      t.timestamps
    end

    add_index :pricing_maps, :service_id
  end
end
