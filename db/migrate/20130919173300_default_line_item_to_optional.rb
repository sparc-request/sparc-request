class DefaultLineItemToOptional < ActiveRecord::Migration
  def up
    change_column_default :line_items, :optional, true
  end

  def down
    change_column_default :line_items, :optional, nil
  end
end
