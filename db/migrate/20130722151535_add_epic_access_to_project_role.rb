class AddEpicAccessToProjectRole < ActiveRecord::Migration
  def change
    add_column :project_roles, :epic_access, :boolean, :default => false
  end
end
