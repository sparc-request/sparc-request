class RemoveDisplayOrderFromSurveys < ActiveRecord::Migration[5.1]
  def up
    remove_column :surveys, :display_order
  end

  def down
    add_column :sections, :display_order, :integer
  end
end
