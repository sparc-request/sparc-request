desc 'Remove nexus pricing maps created on or after 08-01-2015'
task remove_nexus_pricing_maps: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def get_nexus_pricing_maps
    PricingMap.joins(service: :organization).where(organizations: {parent_id: 14})
  end

  def maps_to_be_deleted
    maps = get_nexus_pricing_maps
    maps_to_delete = []

    maps.each do |map|
      if (map.created_at >= "08/01/2015") && (map.service.pricing_maps.count != 1)
        maps_to_delete << map
      end
    end

    maps_to_delete
  end

  continue = prompt("Preparing to delete #{maps_to_be_deleted.count}, do you wish to continue? (Yes/No) ")

  if continue == ('Yes' || 'yes')
    puts '#'*30
    puts 'Starting deletions'
    puts '#'*30

    CSV.open("tmp/nexus_deleted_maps.csv", "w+") do |csv|
      csv << ['Core', 'Service Name', 'CPT code', 'Pricing Map Effective Date']

      maps_to_be_deleted.each do |map|
        csv << [map.service.organization.name, map.service.name, map.effective_date]

        puts "Pricing map with an id of #{map.id} deleted"
        map.destroy
      end
    end
  end
end