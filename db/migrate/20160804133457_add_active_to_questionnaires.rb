class AddActiveToQuestionnaires < ActiveRecord::Migration
  def change
    add_column :questionnaires, :active, :boolean, default: false
  end
end
