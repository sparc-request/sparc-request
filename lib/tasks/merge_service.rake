desc 'Merge an old service into a new service.'

task :merge_service, [:old_service_id, :new_service_id] => :environment do |t, args|
  old_service = Service.find(args[:old_service_id])
  new_service = Service.find(args[:organization_id])
  puts "Merging #{old_service.name} into #{new_service.name}"
  dest_org_process_ssrs = new_service.organization.process_ssrs_parent

  [LineItem, Procedure, ServiceProvider].each do |model|
    model.where(service_id: args[:old_service_id]).each do |obj|
      obj.update!(service_id: args[:new_service_id])
    end
  end

  ActiveRecord::Base.transaction do
    new_service.service_requests.each do |sr|
      # SSR's that contain new_service LineItems
      ssrs = sr.sub_service_requests.
        where.not(organization: dest_org_process_ssrs).
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
            find_or_create_by(organization_id: dest_org_process_ssrs)

          # Move LineItems.
          ssr.line_items.where(service: new_service).each do |li|
            li.update!(sub_service_request: dest_ssr)
          end
        end
      end
    end
  end
end
