module Funding::ServicesHelper

  def display_download_button(service, permission_to_download)
    if permission_to_download
      link_to t(:funding)[:index][:table][:download], funding_service_path(service.id), class: "download-documents btn btn-warning"
    end
  end
  
end