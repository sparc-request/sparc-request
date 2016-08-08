json.(fulfillment)

json.id fulfillment.id
json.fulfillment_date format_date(fulfillment.date)
json.quantity fulfillment.time
json.quantity_type fulfillment.timeframe
json.options fulfillment_options_buttons(fulfillment)
