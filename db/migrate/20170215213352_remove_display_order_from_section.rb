class RemoveDisplayOrderFromSection < ActiveRecord::Migration
  def up
    remove_column :sections, :display_order
  end

  def down
    add_column :sections, :display_order
  end
end
