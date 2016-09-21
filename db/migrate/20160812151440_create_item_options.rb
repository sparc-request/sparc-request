class CreateItemOptions < ActiveRecord::Migration
  def change
    create_table :item_options do |t|
      t.string :content
      t.references :item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
