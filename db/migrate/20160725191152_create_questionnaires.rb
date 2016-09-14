class CreateQuestionnaires < ActiveRecord::Migration
  def change
    create_table :questionnaires do |t|
      t.string :name
      t.references :service, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
