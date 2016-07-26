json.(@past_statuses) do |status|
  json.created_at format_datetime(status.created_at)
  json.changed_from AVAILABLE_STATUSES[status.status]
  json.changed_to AVAILABLE_STATUSES[status.changed_to]
  json.changed_by status.changer.try(:full_name)
end