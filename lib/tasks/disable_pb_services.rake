desc 'Disable PB Services'
task :disable_pb_services => :environment do

  services = Service.where(cpt_code: 80047..89398, organization_id: 144).select{|x| x.name.include?("PB")}

  CSV.open("tmp/disabled_pb_services.csv", "w+") do |csv|
    csv << ['Disabled Services']

    services.each do |service|
      map = service.current_effective_pricing_map
      if (map.federal_rate == 0) && (map.corporate_rate == 0) && (map.other_rate == 0) && (map.member_rate == 0)
        puts "Disabling service #{service.name} with id of #{service.id}"
        service.update_attributes(is_available: false)
        csv << [service.name]
      end
    end
  end
end