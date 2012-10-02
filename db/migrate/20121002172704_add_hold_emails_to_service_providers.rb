class AddHoldEmailsToServiceProviders < ActiveRecord::Migration
  def change
    add_column :service_providers, :hold_emails, :boolean
  end
end
