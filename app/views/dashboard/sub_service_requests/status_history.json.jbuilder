json.(@past_statuses) do |status|
  json.created_at format_datetime(status.date, html: true)
  json.changed_from PermissibleValue.get_value('status', status.status)
  json.changed_to PermissibleValue.get_value('status', status.changed_to)
  json.changed_by status.changer.try(:full_name)
end