module SubsidiesHelper

  def display_requested_funding direct_cost, contribution
    # multiply contribution by 100 to convert to cents
    rf = direct_cost - contribution * 100 rescue 0
    currency_converter(rf)
  end

  def calculate_subsidy_percentage direct_cost, contribution
    # multiply contribution by 100 to convert to cents
    funded_amount = direct_cost - contribution * 100 rescue 0
    ((funded_amount / direct_cost) * 100).round(1)
  end
end