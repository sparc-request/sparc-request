class AddFieldsToPricingMaps < ActiveRecord::Migration
  def change
    change_table :pricing_maps do |t|
      t.datetime :display_date
      t.rename :non_corporate_rate, :federal_rate
      t.decimal :other_rate, :precision => 12, :scale => 4
      t.decimal :member_rate, :precision => 12, :scale => 4
      t.remove :research_rate
    end
  end
end
