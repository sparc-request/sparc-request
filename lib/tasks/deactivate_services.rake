desc "Deactivate services designated in CSV"

task :deactivate_services, [:services_csv] => :environment do |t, args|
  skipped_services = CSV.open("tmp/skipped_active_services_#{Time.now.strftime('%m%d%Y%T')}.csv", "wb")
  skipped_services << ['EAP ID', 'CPT Code', 'Revenue Code', 'Skipped Because']

  CSV.foreach(args[:services_csv], headers: true) do |row|
    service = Service.find_by(eap_id: row["EAP ID"], cpt_code: row["CPT Code"], revenue_code: row["Revenue Code"])

    unless service.update_attributes(is_available: false)
      skipped_services << [row["EAP ID"], row["CPT Code"], row["Revenue Code"], service.errors.full_messages]
    end
  end
end
