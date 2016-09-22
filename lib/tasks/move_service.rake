desc 'Moves a Service to another Organization'

task :move_service, [:service_id, :organization_id] => :environment do |t, args|
  ActiveRecord::Base.transaction do
    service = Service.find(args[:service_id])
    dest_org = Organization.find(args[:organization_id])

    # service will now belong to SSR's with this organization:
    dest_org_process_ssrs = dest_org.process_ssrs_parent

    puts "Moving `#{service.name}` to `#{dest_org.name}`"

    service.service_requests.each do |sr|
      # SSR's that contain LineItems that need to be moved
      ssrs = sr.sub_service_requests.
        where.not(organization: dest_org_process_ssrs).
        joins(:line_items).
        where(line_items: { service_id: service.id })

      ssrs.each do |ssr|
        if ssr_contains_just_this_service?(ssr, service)
          # Don't really need to move anything. Just move the SSR
          # to another Organization.
          ssr.update!(organization_id: dest_org_process_ssrs.id)
        else
          # Find a destination SSR for service. Use an existing one
          # or create one if necessary.
          dest_ssr = sr.sub_service_requests.where(status: ssr.status).
            find_or_create_by(organization_id: dest_org_process_ssrs)

          # Move LineItems.
          ssr.line_items.where(service: service).each do |li|
            li.update!(sub_service_request: dest_ssr)
          end
        end
      end
    end

    service.update!(organization_id: dest_org.id)
  end
end

def ssr_contains_just_this_service?(ssr, service)
  ssr.line_items.pluck(:service_id).uniq == [service.id]
end
