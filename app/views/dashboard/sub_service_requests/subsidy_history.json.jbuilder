json.(@subsidies) do |subsidy|
  json.date             format_datetime(subsidy.approved_at)
  json.request_cost     number_to_currency(subsidy.total_at_approval/100.0)
  json.percent          subsidy.approved_percent_of_total
  json.pi_contribution  number_to_currency(subsidy.pi_contribution/100.0)
  json.subsidy_cost     number_to_currency(subsidy.approved_cost)
  json.approved_by      subsidy.approver.try(:full_name)
end