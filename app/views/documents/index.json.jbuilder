json.(@documents) do |doc|
  json.checkbox     display_check_box(doc)
  json.document     display_document_title(doc)
  json.type         doc.display_document_type
  json.uploaded     format_date(doc.document_updated_at)
  json.shared_with  display_document_providers(doc)
  json.version      format_date(doc.version)
  json.actions      document_actions(doc, srid: @service_request.id)
end
