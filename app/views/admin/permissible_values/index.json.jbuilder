json.(@permissible_values) do |pv|
  json.category     pv.category
  json.key          pv.key
  json.value        pv.value
  json.sort_order   pv.sort_order
  json.default      format_boolean(pv.default)
  json.is_available format_boolean(pv.is_available)
  json.reserved     format_boolean(pv.reserved)
  json.created_at   format_date(pv.created_at)
  json.updated_at   format_date(pv.updated_at)
  json.actions      pv_actions(pv)
end
