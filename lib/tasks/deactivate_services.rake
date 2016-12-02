desc "Deactivate services designated in CSV"

task :deactivate_services, [:services_csv] => :environment do |t, args|
  skipped_services = CSV.open("tmp/skipped_active_services_#{Time.now.strftime('%m%d%Y%T')}.csv", "wb")
  skipped_services << ['EAP ID', 'CPT Code', 'Revenue Code', 'Skipped Because']

  CSV.foreach(args[:services_csv], headers: true) do |row|
    service = Service.find_by(eap_id: row["EAP ID"], cpt_code: row["CPT Code"], revenue_code: row["Revenue Code"])

    if service
      service.assign_attributes({ is_available: false, audit_comment: 'by script' }, without_protection: true)
      service.save
    else
      skipped_services << [row["EAP ID"], row["CPT Code"], row["Revenue Code"], "service not found"]
    end
  end
end
