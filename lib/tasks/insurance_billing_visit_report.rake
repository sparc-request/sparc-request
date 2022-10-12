desc "Find all nexus services that have associated visits that are set to insurance billing"
task :insurance_billing_visit_report => :environment do

  services = []
  progress_bar = ProgressBar.new(Service.count)
  puts "Gathering Nexus services..."
  Service.all.each do |service|
    if service.process_ssrs_organization.id == 14
      services << service
      progress_bar.increment!
    end
  end 

  puts "Generating Report..."

  progress_bar2 = ProgressBar.new(services.count)

  CSV.open("tmp/nexus_services_insurance_billing_report.csv", "wb") do |csv|
    csv << ["Protocol ID", "Short Title", "SSR ID", "Service Name", "Number of Insurance Visits"]

    services.each do |service|
      line_items = service.line_items
      line_items.each do |line_item|
        if !line_item.line_items_visits.first.nil?
          liv = line_item.line_items_visits.first
          arm = liv.arm
          protocol = arm.protocol
          insurance_visits = liv.visits.select{ |visit| visit.insurance_billing_qty >= 1}
          if insurance_visits.any?
            protocol_id = arm.protocol.id
            ssr_id = line_item.sub_service_request.ssr_id
            csv << ["#{protocol_id}", protocol.short_title, ssr_id, service.name, "#{insurance_visits.size}"]
          end
        end
      end
      progress_bar2.increment!
    end
  end
end
