class AddOtherCredentialAndOtherRole < ActiveRecord::Migration
  def up
    add_column :project_roles, :role_other, :string
    add_column :identities, :credentials_other, :string
  end

  def down
    remove_column :identities, :credentials_other
    remove_column :project_roles, :role_other
  end
end
