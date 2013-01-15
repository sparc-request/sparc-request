class FixRoleOther < ActiveRecord::Migration
  def up
    other_project_roles = ProjectRole.all.select{|x| /other -/.match(x.role)}
    other_project_roles.each do |project_role| 
      role,other = project_role.role.split('-')
      project_role.update_attribute(:role, role.strip)
      project_role.update_attribute(:role_other, other.strip)
    end
  end

  def down
  end
end
