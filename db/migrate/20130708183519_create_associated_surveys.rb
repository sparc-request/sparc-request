class CreateAssociatedSurveys < ActiveRecord::Migration
  def change
    create_table :associated_surveys do |t|
      t.integer :surveyable_id
      t.string :surveyable_type
      t.integer :survey_id

      t.timestamps
    end
  end
end
