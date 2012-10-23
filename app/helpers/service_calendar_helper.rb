module ServiceCalendarHelper

  def currency_converter cents
    number_to_currency(Service.cents_to_dollars(cents))
  end

  def display_service_rate line_item
    full_rate = line_item.service.displayed_pricing_map.full_rate

    full_rate < line_item.applicable_rate ? "" : currency_converter(full_rate)
  end

  def display_your_cost line_item
    currency_converter(line_item.applicable_rate)
  end

  #############################################
  # Visit Based Services
  #############################################
  # Displays line item totals
  def display_visit_based_direct_cost line_item
    currency_converter(line_item.direct_costs_for_visit_based_service_single_subject)
  end

  # Displays max totals per patient
  def display_max_total_direct_cost_per_patient service_request
    sum = 0
    sum = service_request.maximum_direct_costs_per_patient
    currency_converter sum
  end

  def display_max_total_indirect_cost_per_patient service_request
    sum = 0
    sum = service_request.maximum_indirect_costs_per_patient
    currency_converter sum
  end

  def display_max_total_cost_per_patient service_request
    sum = service_request.maximum_total_per_patient
    currency_converter sum
  end

  # Displays grand totals per study
  def display_total_direct_cost_per_study_pppvs service_request
    sum = 0
    sum = service_request.total_direct_costs_per_patient
    currency_converter sum
  end

  def display_total_indirect_cost_per_study_pppvs service_request
    sum = 0
    sum = service_request.total_indirect_costs_per_patient
    currency_converter sum
  end

  def display_total_cost_per_study_pppvs service_request
    sum = service_request.total_costs_per_patient
    currency_converter(sum)
  end

  # Displays max totals per patient per visit
  def update_visit_data_cents visit
    visit.cost unless visit.nil?
  end

  #############################################
  # One Time Fee Services
  #############################################
  # Display line item totals
  def display_one_time_fee_direct_cost line_item
    currency_converter line_item.direct_costs_for_one_time_fee
  end

  # Display grand totals per study
  def display_total_direct_cost_per_study_otfs service_request
    sum = 0
    sum = service_request.total_direct_costs_one_time
    currency_converter sum
  end

  def display_total_indirect_cost_per_study_otfs service_request
    sum = 0
    sum = service_request.total_indirect_costs_one_time
    currency_converter sum
  end

  def display_total_cost_per_study_otfs service_request
    sum = 0
    sum = service_request.total_costs_one_time
    currency_converter sum
  end

  #############################################
  # Grand Totals
  #############################################
  def display_grand_total_direct_costs service_request
    sum = 0
    sum = service_request.direct_cost_total
    currency_converter sum
  end

  def display_grand_total_indirect_costs service_request
    sum = 0
    sum = service_request.indirect_cost_total
    currency_converter sum
  end

  def display_grand_total service_request
    sum = 0
    sum = service_request.grand_total
    currency_converter sum
  end


end
