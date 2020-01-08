json.(@funding_documents) do |document|
  ssr = document.sub_service_requests.where(organization_id: Setting.get_value("funding_org_ids")).first

  json.pi display_pi(ssr)
  json.institution display_pi_institution(ssr)
  json.srid ssr.display_id
  json.short_title ssr.protocol.short_title
  json.doc_title display_funding_document_title(document)
  json.uploaded format_datetime(document.document_updated_at, html: true)
  json.status PermissibleValue.get_value('status', ssr.status)
  json.actions display_actions(ssr)
end
