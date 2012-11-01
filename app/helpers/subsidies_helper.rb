module SubsidiesHelper

  def display_requested_funding direct_cost, contribution
    rf = direct_cost / 100 - contribution rescue 0
    currency_converter(rf)
  end

  def calculate_subsidy_percentage direct_cost, contribution
    funded_amount = direct_cost / 100 - contribution rescue 0
    (funded_amount / direct_cost).round(2) * 100
  end
end