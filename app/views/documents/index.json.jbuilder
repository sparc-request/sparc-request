json.(@documents) do |doc|
  json.id           doc.id
  json.type         doc.display_document_type
  json.title        display_document_title(doc)
  json.uploaded     format_datetime(doc.document_updated_at)
  json.actions			document_actions(doc)
  json.shared_with  doc.sub_service_requests.map(&:organization).map(&:name).join('<br>')
end
