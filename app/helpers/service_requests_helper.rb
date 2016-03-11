module ServiceRequestsHelper

  def current_organizations(service_request, sub_service_request)
    organizations = {}
    
    if sub_service_request.present? 
      organizations[sub_service_request.organization_id] = sub_service_request.organization.name
    else
      service_request.sub_service_requests.each do |ssr|
        organizations[ssr.organization_id] = ssr.organization.name
      end
    end

   organizations
  end
end