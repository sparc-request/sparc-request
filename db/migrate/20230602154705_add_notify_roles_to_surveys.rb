class AddNotifyRolesToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :notify_roles, :string, after: :active

    roles = []
    PermissibleValue.where(category: 'user_role').each{|role| roles.push(role.id)}
    Survey.all.update(notify_roles: roles)
  end
end
