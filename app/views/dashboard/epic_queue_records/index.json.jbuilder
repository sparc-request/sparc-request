json.(@epic_queue_records) do |eqr|
  json.protocol_id eqr.protocol.id
  json.protocol format_protocol(eqr.protocol)
  json.pis format_pis(eqr.protocol)
  json.date format_epic_queue_created_at(eqr)
  json.status eqr.status.capitalize
  json.by eqr.try(:identity).try(:full_name)
end
