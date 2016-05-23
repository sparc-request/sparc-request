json.(@epic_queues) do |eq|
  json.protocol         format_protocol(eq.protocol)
  json.pis              format_protocol(eq.protocol)
  json.date             format_protocol(eq.protocol)
  json.status           format_protocol(eq.protocol)
  json.delete           format_protocol(eq.protocol)
end