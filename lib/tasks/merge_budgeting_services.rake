task merge_budgeting_services: :environment do

  service1 = Service.find 34079
  service2 = Service.find 33966
  service2.organization_id = service1.organization_id
  service1.destroy
  service2.save(validate: false)
  line_items = LineItem.where(service_id: service2.id)
  line_items.each do |item|
    puts "Changing sub service request #{item.sub_service_request.id} org id from #{item.sub_service_request.organization_id} to #{service2.organization_id}"
    item.sub_service_request.organization_id = service2.organization_id
    item.sub_service_request.save(validate: false)
  end
end