json.(@documents) do |doc|
	json.id doc.id
	json.type doc.display_document_type
	json.title display_document_title(doc)
	json.uploaded format_date(doc.created_at)
	json.edit document_edit_button(@permission_to_edit)
	json.delete document_delete_button(@permission_to_edit)
end