class RemoveDisplayOrderFromSection < ActiveRecord::Migration[4.2]
  def up
    remove_column :sections, :display_order
  end

  def down
    add_column :sections, :display_order
  end
end
