json.(@documents) do |doc|
  json.document     display_document_title(doc)
  json.type         doc.display_document_type
  json.uploaded     format_datetime(doc.document_updated_at)
  json.shared_with  doc.sub_service_requests.map(&:organization).map(&:name).join('<br>')
  json.actions      document_actions(doc, srid: @service_request.id)
end
