class AddNewTimelineFieldsToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :initial_budget_sponsor_received_date, :datetime, after: :end_date
    add_column :protocols, :budget_agreed_upon_date, :datetime, after: :initial_budget_sponsor_received_date
  end
end
