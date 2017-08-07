namespace :data do
  task create_editable_statuses_data: :environment do
    if defined?(EDITABLE_STATUSES)
      EDITABLE_STATUSES.each do |org_id, statuses|
        organization = Organization.find(org_id)
        (statuses << 'first_draft').each do |status|
          organization.editable_statuses.create(status: status)
        end
      end

      Organization.where.not(id: EDITABLE_STATUSES.keys).each do |org|
        (AVAILABLE_STATUSES.keys << 'first_draft').each do |status|
          org.editable_statuses.create(status: status)
        end
      end
    else
      Organization.all.each do |org|
        (AVAILABLE_STATUSES.keys << 'first_draft').each do |status|
          org.editable_statuses.create(status: status)
        end
      end
    end
  end
end

