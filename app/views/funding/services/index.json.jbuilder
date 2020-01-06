json.(@services) do |service|
  json.title         service.abbreviation
  json.program       service.organization.name
  json.created       format_date(service.created_at, html: true)
  json.action        display_download_button(service, current_user.is_funding_admin?)
end