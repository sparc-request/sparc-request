class AddBillingManagerToSuperUsers < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    add_column :super_users, :billing_manager, :boolean
  end
end
