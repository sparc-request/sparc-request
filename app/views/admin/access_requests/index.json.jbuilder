json.(@requests) do |request|
  json.ip_address     request.ip_address
  json.access_time    format_datetime(request.created_at)
  json.status         t("admin.applications.access_log.statuses.#{request.status}")
  json.failure_reason request.failure_reason
end
