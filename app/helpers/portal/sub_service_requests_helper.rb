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

  #This is used to filter out ssr's on the cfw home page
  #so that clinical providers can only see ones that are
  #under their core.  Super users and clinical providers on the
  #ctrc can see all ssr's.
  def user_can_view_ssr?(study_tracker, ssr, user)
    can_view = false
    if user.is_super_user? || user.clinical_provider_for_ctrc? || (user.is_service_provider? && (study_tracker == false)) 
      can_view = true
    else
      ssr.line_items.each do |line_item|
        clinical_provider_cores(user).each do |core|
          if line_item.core == core 
            can_view = true
          end
        end
      end
    end

    can_view
  end

  def clinical_provider_cores(user)
    cores = []
    user.clinical_providers.each do |provider|
      cores << provider.core
    end

    cores
  end
end
