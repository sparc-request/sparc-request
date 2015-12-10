class ChangeVisitWindow < ActiveRecord::Migration
  def up
    add_column :visit_groups, :window_after, :integer, :default => 0
    rename_column :visit_groups, :window, :window_before

    visit_groups = VisitGroup.all
    visit_groups.each do |vg|
      if vg.window_before != 0
        vg.window_after = vg.window_before
        vg.save
      end
    end
  end

  def down
    remove_column :visit_groups, :window_after
    rename_column :visit_groups, :window_before, :window
  end
end
