class AddAccessEmptyProtocolsToSuperUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :super_users, :access_empty_protocols, :boolean, default: false
  end
end
