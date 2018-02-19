module Funding::DocumentsHelper
 
  def display_pi(ssr)
    ssr.protocol.primary_principal_investigator.last_name_first
  end

  def display_pi_institution(ssr)
    ssr.protocol.primary_principal_investigator.try(:professional_org_lookup, 'institution')
  end

  def display_srid_link(ssr)
    link_to ssr.display_id, "/dashboard/sub_service_requests/#{ssr.id}", target: :blank
  end

  def display_document_title(document)
    link_to document.document_file_name.humanize, document.document.url
  end

end