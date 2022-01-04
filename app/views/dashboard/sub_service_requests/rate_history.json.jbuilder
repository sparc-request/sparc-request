json.(@rates) do |rate|
  json.service_name rate.line_item.service.name
  json.cpt_code rate.line_item.service.cpt_code
  json.modified_rate number_to_currency(Service.cents_to_dollars(rate.admin_cost))
  json.modified_by rate.identity.try(:full_name)
  json.date_changed format_datetime(rate.created_at)
end
