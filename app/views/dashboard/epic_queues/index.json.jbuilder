json.(@epic_queues) do |eq|
  json.protocol         format_protocol(eq.protocol)
  json.pis              format_pis(protocol)
  json.date             format_epic_queue_date(protocol)
  json.status           format_status(protocol)
  json.delete           epic_queue_delete_button(eq)
end