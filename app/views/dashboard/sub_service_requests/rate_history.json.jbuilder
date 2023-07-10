json.(@rate_changes) do |rate_change|
  json.service_name rate_change.line_item.service.name
  json.cpt_code rate_change.line_item.service.cpt_code
  json.modified_rate rate_change.cost_reset ? "COST RESET" : number_to_currency(Service.cents_to_dollars(rate_change.admin_cost))
  json.modified_by rate_change.identity.try(:full_name)
  json.date_changed format_datetime(rate_change.date_of_change)
end