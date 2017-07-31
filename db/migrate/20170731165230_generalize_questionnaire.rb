class GeneralizeQuestionnaire < ActiveRecord::Migration[5.1]
  def change
    rename_column :questionnaires, :service_id, :questionable_id
    add_column :questionnaires, :questionable_type, :string, after: :questionable_id
  end
end
