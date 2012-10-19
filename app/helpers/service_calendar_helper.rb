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
  # 
  def display_visit_based_direct_cost line_item
    currency_converter(line_item.direct_costs_for_visit_based_service_single_subject)
  end

  def max_total_cost_per_patient line_items, cost_type
    sum = 0
    line_items.each do |li|
      sum += (cost_type == "Direct") ? li.direct_costs_for_visit_based_service_single_subject : li.indirect_costs_for_visit_based_service_single_subject
    end
    sum
  end

  def dispaly_max_total_direct_cost_per_patient line_items
    currency_converter(max_total_cost_per_patient(line_items, "Direct"))
  end

  def dispaly_max_total_indirect_cost_per_patient line_items
      currency_converter(max_total_cost_per_patient(line_items, "Indirect"))
  end

  def dispaly_max_total_cost_per_patient line_items
    sum = max_total_cost_per_patient(line_items, "Direct") + max_total_cost_per_patient(line_items, "Indirect")
    currency_converter(sum)
  end

  # Per Study
  def total_cost_per_study line_items, cost_type
    sum = 0
    line_items.each do |li|
      sum += (cost_type == "Direct") ? li.direct_costs_for_visit_based_service : li.indirect_costs_for_visit_based_service
    end
    sum
  end

  def dispaly_total_direct_cost_per_study line_items
    currency_converter(total_cost_per_study(line_items, "Direct"))
  end

  def dispaly_total_indirect_cost_per_study line_items
    currency_converter(total_cost_per_study(line_items, "Indirect"))
  end

  def dispaly_total_cost_per_study line_items
    sum = total_cost_per_study(line_items, "Direct") + total_cost_per_study(line_items, "Indirect")
    currency_converter(sum)
  end
  # End Per Study
  #############################################
  # End Visit Based Services
  #############################################


end