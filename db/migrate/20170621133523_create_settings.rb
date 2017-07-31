class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :key
      t.text :value
      t.string :data_type
      t.string :friendly_name
      t.text :description
      t.integer :group
      t.string :version
      t.string :parent_key
      t.string :parent_value
      t.timestamps null: false
    end

    add_index :settings, :key, unique: true
  end
end