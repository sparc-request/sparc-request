json.(@oncore_records) do |ocr|
  json.calendar_version   ocr.calendar_version
  json.status             ocr.status.capitalize
  json.created_at         format_push_date(ocr.created_at)
end
