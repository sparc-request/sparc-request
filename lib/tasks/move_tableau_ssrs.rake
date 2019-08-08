task move_tableau_data: :environment do

  service = Service.find 37990
  line_items = LineItem.where(service_id: service.id)

  service.organization_id = 311
  service.save(validate: false)

  line_items.each do |item|
    item.sub_service_request.organization_id = 311
    item.sub_service_request.save(validate: false)
  end
end