json.(@documents) do |doc|
  has_access_to_doc = @permission_to_edit || (@admin_orgs & doc.all_organizations).any?

	json.id doc.id
	json.type doc.display_document_type
	json.title display_document_title(doc, has_access_to_doc)
	json.uploaded format_date(doc.created_at)
	json.edit document_edit_button(doc, has_access_to_doc)
	json.delete document_delete_button(doc, has_access_to_doc)
end