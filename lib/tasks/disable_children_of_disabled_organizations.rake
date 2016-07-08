desc 'Disable children of disabled organizations'
task disable_child_orgs: :environment do

  organizations = Organizations.where(is_available: false)

  organizations.each do |org|
    org.update_descendants_availability(false)
    puts "Updated child organizations of #{org.name} (#{org.type})"
  end

end