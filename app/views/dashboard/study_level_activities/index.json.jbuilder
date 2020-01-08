json.(@line_items) do |line_item|
  json.service            sla_service_name_display(line_item)
  json.fulfillments       sla_fulfillments_button(line_item)
  json.notes              notes_button(line_item, ssrid: @sub_service_request.id)
  json.units_requested    line_item.units_per_quantity
  json.unit_type          line_item.service.current_effective_pricing_map.otf_unit_type
  json.quantity_requested line_item.quantity
  json.quantity_type      line_item.service.current_effective_pricing_map.quantity_type
  json.service_rate       sla_service_rate_display(line_item)
  json.cost               sla_your_cost_field(line_item)
  json.total              display_one_time_fee_direct_cost(line_item)
  json.date_started       format_date(line_item.in_process_date, html: true)
  json.date_completed     format_date(line_item.complete_date, html: true)
  json.actions            sla_actions(line_item)
end
