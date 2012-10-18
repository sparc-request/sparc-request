module ServiceCalendarHelper

  def display_service_rate line_item
    full_rate = line_item.service.displayed_pricing_map.full_rate

    full_rate < line_item.applicable_rate ? "" : number_to_currency(Service.cents_to_dollars(full_rate))
  end

  def display_your_cost line_item
    number_to_currency Service.cents_to_dollars(line_item.applicable_rate)
  end

  def display_visit_based_direct_cost line_item
    number_to_currency Service.cents_to_dollars(line_item.direct_costs_for_visit_based_service)
  end
end