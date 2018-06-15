module Funding::DocumentsHelper
 
  def display_pi(ssr)
    ssr.protocol.primary_principal_investigator.last_name_first
  end

  def display_pi_institution(ssr)
    ssr.protocol.primary_principal_investigator.try(:professional_org_lookup, 'institution')
  end

  def display_actions(ssr)
    protocol_button(ssr) +
    admin_edit_button(ssr)
  end

  def display_funding_document_title(document)
    link_to document.document_file_name.humanize, document.document.url, download: document.document_file_name.humanize, 'data-toggle' => 'tooltip', 'data-placement' => 'right'
  end

  private

  def protocol_button(ssr)
    link_to t(:funding)[:download][:table][:actions][:protocol], "/dashboard/protocols/#{ssr.protocol.id}", class: "btn btn-success btn-sm protocol-btn", target: :blank  
  end

  def admin_edit_button(ssr)
    link_to t(:funding)[:download][:table][:actions][:admin_edit], "/dashboard/sub_service_requests/#{ssr.id}", class: "btn btn-warning btn-sm admin-edit-btn", target: :blank
  end

end
