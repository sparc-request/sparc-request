class CreateSystemAdminIdentity < ActiveRecord::Migration[6.1]
  def change
    add_column :identities, :system_admin, :boolean
  end
end
