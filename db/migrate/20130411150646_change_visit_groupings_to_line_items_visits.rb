class ChangeVisitGroupingsToLineItemsVisits < ActiveRecord::Migration
  def up
  	rename_table :visit_groupings, :line_items_visits
  	rename_column :visits, :visit_grouping_id, :line_items_visit_id
  end

  def down
  	rename_table :line_items_visits, :visit_groupings
  	rename_column :visits, :line_items_visit_id, :visit_grouping_id
  end
end
