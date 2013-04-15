class MovePositionFromVisitToVisitGroup < ActiveRecord::Migration
  def up
  	add_column :visit_groups, :position, :integer
  	remove_column :visits, :position
  end

  def down
  	add_column :visits, :position, :integer
  	remove_column :visit_groups, :position
  end
end
