module Portal::SubServiceRequestsHelper

  def candidate_service_options services
    services.map {|x| [x.name, x.id]}
  end

end
