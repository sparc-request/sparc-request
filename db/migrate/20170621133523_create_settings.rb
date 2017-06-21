class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :key
      t.text :value
      t.string :type
      t.string :friendly_name
      t.string :description
      t.integer :group
      t.string :version
      t.timestamps null: false
    end
  end

  add_index :settings, :key, unique: true
end