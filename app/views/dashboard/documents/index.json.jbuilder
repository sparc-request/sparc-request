json.(@documents) do |doc|
  permission = current_user.catalog_overlord? || @permission_to_edit || (@admin_orgs & doc.all_organizations).any?

  json.document    display_document_title(doc, permission: permission)
  json.type        doc.display_document_type
  json.uploaded    format_datetime(doc.document_updated_at, html: true)
  json.shared_with display_document_providers(doc)
  json.actions     document_actions(doc, permission: permission)
end
