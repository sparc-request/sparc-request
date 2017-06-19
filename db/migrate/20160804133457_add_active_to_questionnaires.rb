class AddActiveToQuestionnaires < ActiveRecord::Migration[4.2]
  def change
    add_column :questionnaires, :active, :boolean, default: false
  end
end
