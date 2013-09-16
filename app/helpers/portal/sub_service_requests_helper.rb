module Portal::SubServiceRequestsHelper

  def candidate_service_options(services, include_cpt=false)
    services.map do |service|
      n = include_cpt ? service.display_service_name : service.name
      [n, service.id]
    end
  end

  def per_patient_line_items(line_items)
    line_items.map { |line_item| [line_item.service.name, line_item.id]}
  end

  def calculate_total
    if @sub_service_request
      total = @sub_service_request.direct_cost_total / 100
    end

    total
  end

end
