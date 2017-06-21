class CreatePermissibleValues < ActiveRecord::Migration[5.0]
  def change
    create_table :permissible_values do |t|
      t.string :key
      t.string :value
      t.string :concept_code
      t.integer :parent_id
      t.integer :sortorder
      t.string :category
      t.boolean :default
      t.boolean :reserved

      t.timestamps
    end
  end
end
