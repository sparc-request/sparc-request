desc 'Merge an old service into a new service.'

task :merge_services, [:services_list] => :environment do |t, args|
  skipped_services = CSV.open("tmp/skipped_merged_services_#{Time.now.strftime('%m%d%Y%T')}.csv", "wb")
  ActiveRecord::Base.transaction do
    CSV.foreach(args[:services_list], headers: true) do |row|
      begin
        merge_service(row['Old Service ID'].strip, row['New Service ID'].strip)
      rescue
        skipped_services << row
      end
    end
  end
end

def merge_service(old_service_id, new_service_id)
  old_service = Service.find(old_service_id)
  new_service = Service.find(new_service_id)
  dest_org_process_ssrs = new_service.organization.process_ssrs_parent
  puts "Merging #{old_service.name} into #{new_service.name} belonging to org ##{dest_org_process_ssrs.inspect}"

  [LineItem, Procedure, ServiceProvider].each do |model|
    model.where(service_id: old_service_id).each do |obj|
      obj.update!(service_id: new_service_id)
    end
  end

  new_service.service_requests.each do |sr|
    # SSR's that contain new_service LineItems
    ssrs = sr.sub_service_requests.
      where.not(organization_id: dest_org_process_ssrs.id).
      joins(:line_items).
      where(line_items: { service_id: new_service.id })

    ssrs.each do |ssr|
      if ssr_contains_just_this_service?(ssr, new_service)
        # Don't really need to move anything. Just move the SSR
        # to another Organization.
        ssr.update!(organization_id: dest_org_process_ssrs.id)
      else
        # Find a destination SSR for service. Use an existing one
        # or create one if necessary.
        dest_ssr = sr.sub_service_requests.where(status: ssr.status).
          find_or_create_by(organization_id: dest_org_process_ssrs.id)

        # Move LineItems.
        ssr.line_items.where(service: new_service).each do |li|
          li.update!(sub_service_request_id: dest_ssr.id)
        end
      end
    end
  end
end
