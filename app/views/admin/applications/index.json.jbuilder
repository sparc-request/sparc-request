json.(@applications) do |app|
  json.name       admin_application_name(app)
  json.uid        content_tag(:span, app.uid, class: 'text-muted')
  json.created_at format_date(app.created_at)
end
