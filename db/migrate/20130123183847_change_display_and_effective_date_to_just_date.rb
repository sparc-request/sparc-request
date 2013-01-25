class ChangeDisplayAndEffectiveDateToJustDate < ActiveRecord::Migration
  def up
    change_column :pricing_setups, :display_date, :date
    change_column :pricing_setups, :effective_date, :date
    change_column :pricing_maps, :display_date, :date
    change_column :pricing_maps, :effective_date, :date
  end

  def down
  end
end
