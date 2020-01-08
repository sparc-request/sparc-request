json.(@subsidies) do |subsidy|
  json.date             format_datetime(subsidy.approved_at, html: true)
  json.request_cost     number_to_currency(subsidy.total_at_approval/100.0)
  json.percent          (subsidy.percent_subsidy * 100.0).round(2)
  json.pi_contribution  number_to_currency(subsidy.pi_contribution/100.0)
  json.subsidy_cost     number_to_currency(subsidy.approved_cost)
  json.approved_by      subsidy.approver.try(:full_name)
  json.action           subsidy_history_action(subsidy)
end
