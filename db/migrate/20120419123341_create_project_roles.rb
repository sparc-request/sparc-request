class CreateProjectRoles < ActiveRecord::Migration
  def change
    create_table :project_roles do |t|
      t.integer :protocol_id
      t.integer :identity_id
      t.string :project_rights
      t.string :role

      t.timestamps
    end

    add_index :project_roles, :protocol_id
  end
end
