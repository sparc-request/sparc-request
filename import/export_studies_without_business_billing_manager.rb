# Run this script with:
#   rails runner import/export_studies_without_business_billing_manager.rb > file.csv

require 'csv'

csv = CSV.new(STDOUT)

#<Study id: 1, type: "Study", obisid: nil, next_ssr_id: nil, short_title: "short title", title: "long title", sponsor_name: nil, brief_description: nil, indirect_cost_rate: nil, study_phase: nil, udak_project_number: nil, funding_rfa: nil, funding_status: nil, potential_funding_source: nil, potential_funding_start_date: nil, funding_source: nil, funding_start_date: nil, federal_grant_serial_number: nil, federal_grant_title: nil, federal_grant_code_id: nil, federal_non_phs_sponsor: nil, federal_phs_sponsor: nil, created_at: "2013-03-08 21:18:46", updated_at: "2013-03-08 21:18:46", deleted_at: nil, potential_funding_source_other: nil, funding_source_other: nil>
csv << [ 'created_at', 'id', 'short_title', 'title', 'billing/business manager netid' ]
Protocol.all.each do |protocol|
  if not protocol.project_roles.map(&:role).include?('billing-business-manager') then
    csv << [
      protocol.created_at,
      protocol.id,
      protocol.short_title,
      protocol.title,
      ''
    ]
  end
end

