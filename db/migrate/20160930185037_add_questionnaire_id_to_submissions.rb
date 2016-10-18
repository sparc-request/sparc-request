class AddQuestionnaireIdToSubmissions < ActiveRecord::Migration
  def change
    add_reference :submissions, :questionnaire, index: true, foreign_key: true, after: :identity_id
  end
end
