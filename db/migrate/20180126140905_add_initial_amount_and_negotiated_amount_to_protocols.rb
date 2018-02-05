class AddInitialAmountAndNegotiatedAmountToProtocols < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :initial_amount, :decimal, precision: 8, scale: 2, after: :budget_agreed_upon_date
    add_column :protocols, :negotiated_amount, :decimal, precision: 8, scale: 2, after: :initial_amount
  end
end
