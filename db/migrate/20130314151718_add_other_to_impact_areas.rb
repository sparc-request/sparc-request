class AddOtherToImpactAreas < ActiveRecord::Migration
  def change
    add_column :impact_areas, :other_text, :string
  end
end
