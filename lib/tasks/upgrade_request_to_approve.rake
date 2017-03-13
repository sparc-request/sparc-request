namespace :data do
  task upgrade_request_to_approve: :environment do
    project_roles = ProjectRole.where(
      project_rights: 'request'
    )

    project_roles.each do |pr|
      pr.update_attribute(:project_rights, 'approve')
    end
  end
end
