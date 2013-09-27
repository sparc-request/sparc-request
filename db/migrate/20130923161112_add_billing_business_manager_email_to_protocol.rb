class AddBillingBusinessManagerEmailToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :billing_business_manager_static_email, :string
  end
end
