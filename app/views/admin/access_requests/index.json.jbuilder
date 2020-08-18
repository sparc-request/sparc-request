json.(@requests) do |request|
  json.ip_address   request.ip_address
  json.access_time  format_date(request.created_at)
  status            t("admin.applications.access_log.statuses.#{request.status}")
  failure_reason    request.failure_reason
end
