class AddNotifyRequesterToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :notify_requester, :boolean, after: :notify_roles, default: true

    
    # Set default roles
    roles = []
    PermissibleValue.where(category: 'user_role', key: 'primary-pi').each{|role| roles.push(role.id)}
    Survey.all.update(notify_roles: roles)
  end
end
