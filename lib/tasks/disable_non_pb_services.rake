# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
##### this task is very specific to a MUSC data import.  it should not be used otherwise #####

desc 'Disable non-PB Services'
task :disable_non_pb_services => :environment do

  services = Service.where(organization_id: [70, 71]).reject{|x| x.name.include?("PB")}

  services.each do |service|
    puts "Disabling service #{service.name} with id of #{service.id}"
    service.update_attributes(is_available: false)
  end
end