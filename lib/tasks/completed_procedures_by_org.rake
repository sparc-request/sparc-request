# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
task :completed_procedures => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end
  
  puts ""
  puts ""
  puts "This task will display all completed procedures for all services under an organization."
  org_id = prompt ("Enter the organization id: ").to_i

  completed_procedures = Procedure.where(:completed => true)
  services = Service.where(:organization_id => org_id)
  service_ids = services.map(&:id)
  procedures_for_services = []

  completed_procedures.each do |procedure|
    if procedure.service.present?
      if service_ids.include?(procedure.service_id)
        procedures_for_services << procedure
      end
    elsif procedure.line_item.present?
      if service_ids.include?(procedure.line_item.service_id)
        procedures_for_services << procedure
      end
    end
  end

  grouped = procedures_for_services.group_by(&:direct_service)
  grouped.each do |service, procedures|
    puts "For #{service.name} we have #{procedures.count} completed procedures."
  end

end