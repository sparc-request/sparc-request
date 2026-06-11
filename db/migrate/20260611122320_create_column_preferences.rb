class CreateColumnPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :column_preferences do |t|
      t.belongs_to :identity, foreign_key: true
      t.string :table_id
      t.text :column_preferences

      t.timestamps
    end
  end
end
