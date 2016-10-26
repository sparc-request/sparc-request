class CreateQuestionnaireResponses < ActiveRecord::Migration
  def change
    create_table :questionnaire_responses do |t|
      t.references :submission, index: true, foreign_key: true
      t.references :item, index: true, foreign_key: true
      t.text :content

      t.timestamps null: false
    end
  end
end
