# Run this script with:
#   rails runner import/export_studies_without_business_billing_manager.rb < file.csv

require 'csv'

csv = CSV.new(STDIN, headers: true)

ActiveRecord::Base.transaction do
  csv.each do |row|
    p row
    protocol_id = row['id']
    ldap_uid = row['billing/business manager netid']

    protocol = Protocol.find(protocol_id)
    identity = Identity.find_by_ldap_uid(ldap_uid)
    raise "Could not find identity with ldap uid `#{ldap_uid}'" if not identity

    puts "Adding #{identity.ldap_uid} as billing/business manager for study `#{protocol.short_title}' (id #{protocol.id})"
    ProjectRole.create!(
        protocol_id:     protocol.id,
        identity_id:     identity.id,
        project_rights:  "approve",
        role:            "billing-business-manager")
  end
end

