class AddSubspecialtyToProjectRoles < ActiveRecord::Migration
  def change
    add_column :project_roles, :subspecialty, :string
  end
end
