class AddHoldEmailsToSuperUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :super_users, :hold_emails,  :boolean, default: true
  end
end
