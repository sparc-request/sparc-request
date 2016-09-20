json.(line_item)

json.id line_item.id
json.service sla_service_name_display(line_item)
json.charge_code line_item.service.charge_code
json.quantity_requested line_item.quantity
json.quantity_type line_item.service.current_effective_pricing_map.quantity_type
json.unit_requested line_item.units_per_quantity
json.unit_type line_item.service.current_effective_pricing_map.otf_unit_type
json.cost sla_cost_display(line_item)
json.date_started format_date(line_item.in_process_date)
json.date_completed format_date(line_item.complete_date)
json.options sla_options_buttons(line_item)
json.fulfillments_button fulfillments_drop_button(line_item.id)
