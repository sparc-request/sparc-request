class RemoveSsrIdFromLineItems < ActiveRecord::Migration
  def up
    remove_column :line_items, :ssr_id
  end

  def down
    add_column :line_items, :ssr_id, :string
  end
end
