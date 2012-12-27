class MoveSubspecialtyToIdentityModel < ActiveRecord::Migration
  def change
    remove_column :project_roles, :subspecialty
  end
end
