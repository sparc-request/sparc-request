json.(@funding_documents) do |document|
  ssr = document.sub_service_requests.where(organization_id: Setting.find_by_key("funding_org_ids").value).first

  json.pi display_pi(ssr)
  json.institution display_pi_institution(ssr)
  json.srid ssr.display_id
  json.short_title ssr.protocol.short_title
  json.doc_title display_funding_document_title(document)
  json.uploaded format_datetime(document.document_updated_at)
  json.status PermissibleValue.get_value('status', ssr.status)
  json.actions display_actions(ssr)
end
