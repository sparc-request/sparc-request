json.(@documents) do |doc|
  permission = current_user.catalog_overlord? || @permission_to_edit || (@admin_orgs & doc.all_organizations).any?

  json.checkbox    display_check_box(doc, permission: permission )
  json.document    display_document_title(doc, permission: permission)
  json.type        doc.display_document_type
  json.uploaded    format_datetime(doc.updated_at)
  json.shared_with display_document_providers(doc)
  json.version     format_date(doc.version)
  json.actions     document_actions(doc, permission: permission)
end
