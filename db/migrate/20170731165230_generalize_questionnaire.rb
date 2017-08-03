class GeneralizeQuestionnaire < ActiveRecord::Migration[5.1]
  def change
    rename_column :questionnaires, :service_id, :questionable_id
    add_column :questionnaires, :questionable_type, :string, after: :questionable_id
    Questionnaire.find_each{ |q| q.update(questionable_type: 'Service')}
  end
end
