desc "Move ct.gov services underneath a new organization"
task move_ct_orgs: :environment do

  services = Service.find(199, 8288, 37255)

  services.each do |service|
    puts "Updating service #{service.id}"
    service.update_attributes(organization_id: 284)
    service.line_items.each do |line_item|
      puts "Updating line item #{line_item.id} and ssr #{line_item.sub_service_request_id}"
      line_item.sub_service_request.update_attributes(organization_id: 284)
    end
  end
end