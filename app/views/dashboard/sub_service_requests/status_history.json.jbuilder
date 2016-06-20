json.(@past_statuses) do |status|
  json.created_at format_date(status.created_at)
  json.changed_from AVAILABLE_STATUSES[status.status]
  json.changed_to AVAILABLE_STATUSES[status.changed_to]
end