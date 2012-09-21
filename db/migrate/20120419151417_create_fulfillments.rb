class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.integer :line_item_id
      t.string :timeframe
      t.text :notes
      t.string :time
      t.datetime :date

      t.timestamps
    end

    add_index :fulfillments, :line_item_id
  end
end
