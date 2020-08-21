json.(@oncore_records) do |ocr|
  json.protocol           format_protocol(ocr.protocol)
  json.pis                pis_display(ocr.protocol)
  json.calendar_version   ocr.calendar_version
  json.status             ocr.status.capitalize
  json.created_at         format_push_date(ocr.created_at)
  json.history            protocol_oncore_history_button(ocr.protocol_id)
end
