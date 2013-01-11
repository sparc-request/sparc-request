module Portal::SubServiceRequestsHelper

  def candidate_service_options(services, include_cpt=false)
    services.map do |service|
      n = include_cpt ? service.display_service_name : service.name
      [n, service.id]
    end
  end

end
