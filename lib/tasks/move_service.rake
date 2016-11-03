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

          # Is this probably a newly created SSR?
          if !dest_ssr.ssr_id && !dest_ssr.service_requester_id && !dest_ssr.owner_id
            # Move over old SSR attributes.
            old_attributes = ssr.attributes
            # ! needed, since only it will return the _other_ attributes.
            copy_over_attributes = old_attributes.
              slice!(*%w(id ssr_id organization_id org_tree_display status))
            dest_ssr.assign_attributes(copy_over_attributes, without_protection: true)
            dest_ssr.save(validate: false)
            dest_ssr.update_org_tree
            ssr.service_request.ensure_ssr_ids
          end

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
