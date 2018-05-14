json.(@funding_documents) do |document|
  ssr = document.sub_service_requests.where(organization_id: Setting.get_value("funding_org_ids")).first
  json.pi display_pi(ssr)
  json.institution display_pi_institution(ssr)
  json.srid display_srid_link(ssr)
  json.protocol ssr.protocol.title
  json.doc_title display_document_title(document)
  json.uploaded format_datetime(document.document_updated_at)
  json.status PermissibleValue.get_value('status', ssr.status)
  json.id ssr.id
end
