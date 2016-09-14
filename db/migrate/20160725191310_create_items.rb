class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.text :content
      t.string :item_type
      t.text :description
      t.boolean :required
      t.references :questionnaire, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
