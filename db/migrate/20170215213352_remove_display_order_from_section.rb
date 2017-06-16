class RemoveDisplayOrderFromSection < ActiveRecord::Migration[5.1]
  def up
    remove_column :sections, :display_order
  end

  def down
    add_column :sections, :display_order
  end
end
