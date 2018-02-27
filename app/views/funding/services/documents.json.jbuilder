json.(@funding_documents) do |document|
  ssr = document.sub_service_requests.where(organization_id: Setting.find_by_key("funding_org_ids").value).first
  json.pi display_pi(ssr)
  json.institution display_pi_institution(ssr)
  json.srid display_srid_link(ssr)
  json.protocol ssr.protocol.title
  json.doc_title display_document_title(document)
  json.uploaded format_date(document.document_updated_at)
  json.status PermissibleValue.get_value('status', ssr.status)
  json.id ssr.id
end
