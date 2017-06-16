class AddRequiredToQuestionnaireResponses < ActiveRecord::Migration[5.1]
  def change
    add_column :questionnaire_responses, :required, :boolean, after: :content, default: false
  end
end
