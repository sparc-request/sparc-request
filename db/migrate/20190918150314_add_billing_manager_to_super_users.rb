class AddBillingManagerToSuperUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :super_users, :billing_manager, :boolean
  end
end
