class FixOptionalLineItemBoolean < ActiveRecord::Migration
  def up
    line_items = LineItem.where(:optional => nil)
    line_items.each{|li| li.update_attribute(:optional, true)}
  end

  def down
  end
end
