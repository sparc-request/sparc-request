json.(@documents) do |doc|
  json.id doc.id
  json.type doc.display_document_type
  json.title display_document_title(doc)
  json.uploaded format_date(doc.created_at)
  json.actions display_document_actions
end