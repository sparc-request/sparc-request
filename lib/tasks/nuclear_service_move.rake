task nuclear_service_move: :environment do

  services = Service.where("organization_id = ?", 200).where("revenue_code = ? OR revenue_code = ?", '0404', '0499')
  services.each do |service|
    service.organization_id = 195
    service.save(validate: false)
    service.line_items.each do |item|
      item.sub_service_request.organization_id = 195
      item.sub_service_request.save(validate: false)
    end
  end
end