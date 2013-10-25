class AddDayAndWindowToVisitGroups < ActiveRecord::Migration
  def change
    add_column :visit_groups, :day, :integer
    add_column :visit_groups, :window, :integer, :default => 0
  end
end
