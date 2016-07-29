json.(@documents) do |doc|
  json.id           doc.id
  json.type         doc.display_document_type
  json.title        display_document_title(doc)
  json.uploaded     format_date(doc.created_at)
  json.edit         documents_edit_button(doc)
  json.delete       documents_delete_button(doc)
  json.shared_with  doc.sub_service_requests.map(&:organization).map(&:name).join('<br>')
end
