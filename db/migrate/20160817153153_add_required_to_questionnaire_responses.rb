class AddRequiredToQuestionnaireResponses < ActiveRecord::Migration
  def change
    add_column :questionnaire_responses, :required, :boolean, after: :content, default: false
  end
end
