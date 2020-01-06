json.(@fulfillments) do |fulfillment|
  json.fulfillment_date format_date(fulfillment.date, html: true)
  json.quantity         fulfillment.time
  json.quantity_type    fulfillment.timeframe
  json.notes            notes_button(fulfillment, ssrid: @sub_service_request.id)
  json.actions          fulfillment_actions(fulfillment, @sub_service_request)
end
