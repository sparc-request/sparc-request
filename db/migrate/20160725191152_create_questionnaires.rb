class CreateQuestionnaires < ActiveRecord::Migration[4.2]
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.references :service, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
