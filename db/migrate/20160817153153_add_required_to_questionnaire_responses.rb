class AddRequiredToQuestionnaireResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :questionnaire_responses, :required, :boolean, after: :content, default: false
  end
end
