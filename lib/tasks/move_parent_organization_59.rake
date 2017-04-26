namespace :data do
  task move_parent_organization_59: :environment do
    organization = Organization.find(59)

    puts "Updating #{organization.name}..."

    organization.update_attribute(:parent_id, 245)

    puts "#{organization.name} now lives under #{Organization.find(245).name}"
  end
end
