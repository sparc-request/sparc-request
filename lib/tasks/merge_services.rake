desc 'Merge an old service into a new service (example only).'

task :merge_services, [:services_list] => :environment do |t, args|
  skipped_services = CSV.open("tmp/skipped_merged_services_#{Time.now.strftime('%m%d%Y%T')}.csv", "wb")
  ActiveRecord::Base.transaction do
    # "Merge" old services into corresponding new ones.
    CSV.foreach(args[:services_list], headers: true) do |row|
      begin
        merge_service(row['Old Service ID'].strip, row['New Service ID'].strip)
      rescue
        skipped_services << row
      end
    end

    # 68 no longer a process_ssrs. Fix organization_id on SSR's belonging to 68.
    # Only care about SSR's with LineItems.
    ssrs = SubServiceRequest.where(organization_id: 68).joins(:line_items)
    ssrs.each do |ssr|
      # Pick an arbitrary service, and make
      # ssr belong to the service's process_ssrs_parent.
      process_ssrs_parent = ssr.line_items.first.service.organization.process_ssrs_parent

      if process_ssrs_parent
        ssr.update!(organization_id: process_ssrs_parent.id)
      end
    end

    # Great. Now shuffle LineItems between SSR's as needed
    ssrs_count = ssrs.length
    ssrs_processed = 0
    ssrs.each do |ssr|
      ssr.reload
      ssrs_processed += 1
      puts "Processing SSR #{ssrs_processed}/#{ssrs_count}"

      # Make sure each LineItem in proper SSR.
      ssr.line_items.each do |li|
        process_ssrs_parent = li.service.organization.process_ssrs_parent

        # If li shouldn't belong to ssr.
        if process_ssrs_parent.id != ssr.organization_id
          # Create/find SubServiceRequest for li.
          dest_ssr = ssr.service_request.sub_service_requests.
            where(status: ssr.status).
            find_or_create_by(organization_id: process_ssrs_parent.id)

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

          # Move li.
          li.update!(sub_service_request_id: dest_ssr.id)
        end
      end # ssr.line_items.each
    end # ssrs.each
  end # ActiveRecord::Base.transaction
end # task

def merge_service(old_service_id, new_service_id)
  old_service = Service.find(old_service_id)
  new_service = Service.find(new_service_id)
  dest_org_process_ssrs = new_service.organization.process_ssrs_parent
  puts "Merging Service #{old_service.id} into #{new_service.id} belonging to Org ##{dest_org_process_ssrs.id}"

  [LineItem, Procedure, ServiceProvider].each do |model|
    model.where(service_id: old_service_id).each do |obj|
      obj.update!(service_id: new_service_id)
    end
  end

  old_service.destroy
end

#   new_service.service_requests.each do |sr|
#     # SSR's that contain new_service LineItems
#     ssrs = sr.sub_service_requests.
#       where.not(organization_id: dest_org_process_ssrs.id).
#       joins(:line_items).
#       where(line_items: { service_id: new_service.id })
#
#     ssrs.each do |ssr|
#       if ssr_contains_just_this_service?(ssr, new_service)
#         # Don't really need to move anything. Just move the SSR
#         # to another Organization.
#         ssr.update!(organization_id: dest_org_process_ssrs.id)
#       else
#         # Find a destination SSR for service. Use an existing one
#         # or create one if necessary.
#         dest_ssr = sr.sub_service_requests.where(status: ssr.status).
#           find_or_create_by(organization_id: dest_org_process_ssrs.id)
#
#         # Move over old SSR attributes, if we're creating a new SSR.
#         if ssr.id != dest_ssr.id
#           old_attributes = ssr.attributes
#           # ! needed, since only it will return the _other_ attributes
#           copy_over_attributes = old_attributes.
#             slice!(%w(id ssr_id organization_id))
#           dest_ssr.attributes(copy_over_attributes).save(false)
#         end
#
#         # Move LineItems.
#         ssr.line_items.where(service: new_service).each do |li|
#           li.update!(sub_service_request_id: dest_ssr.id)
#         end
#       end
#     end
#
#     sr.ensure_ssr_ids
#   end
# end
