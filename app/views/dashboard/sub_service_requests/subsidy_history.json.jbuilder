json.(@subsidy_audits) do |audit|
  json.created_at format_date(audit[:created_at])
  json.name full_user_name_from_id(audit[:user_id])
  json.action audit[:action]
  json.pi_contribution extract_subsidy_audit_data(audit[:audited_changes]["pi_contribution"], true)
  json.percent_subsidy extract_subsidy_audit_data(audit[:audited_changes]["stored_percent_subsidy"])
end
