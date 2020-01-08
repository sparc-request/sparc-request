json.(@approvals) do |approval|
  json.date format_datetime(approval.approval_date, html: true)
  json.type approval.approval_type
  json.name approval.identity.full_name
end