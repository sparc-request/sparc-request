class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :line_item_id
      t.integer :quantity
      t.string :billing

      t.timestamps
    end

    add_index :visits, :line_item_id
  end
end
