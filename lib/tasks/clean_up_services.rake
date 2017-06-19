namespace :data do
  task clean_up_services: :environment do
    include ActiveModel::AttributeAssignment

    service_1 = Service.find(494)
    service_1.destroy

    service_2 = Service.find(495)
    new_service_2 = Service.find(485)

    merge_service(service_2.id, new_service_2.id)
    Organization.find(60).destroy

    ssrs = []

    new_service_2.sub_service_requests.each do |ssr|
      if ssr.line_items.empty?
        ssr.destroy
        next
      end
      # Pick an arbitrary service, and make
      # ssr belong to the service's process_ssrs_parent.
      process_ssrs_parent = ssr.line_items.first.service.organization.process_ssrs_parent

      if process_ssrs_parent
        ssr.update!(organization_id: process_ssrs_parent.id)
      end

      ssr.reload
      ssrs << ssr
    end

    # Great. Now shuffle LineItems between SSR's as needed
    ssrs_count = ssrs.length
    ssrs_processed = 0
    ssrs.each do |ssr|
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
            dest_ssr.assign_attributes(copy_over_attributes)
            dest_ssr.assign_attributes(ssr_id: (sprintf '%04d', Protocol.find(dest_ssr.protocol_id).next_ssr_id))
            protocol_to_update = Protocol.find(dest_ssr.protocol_id)
            protocol_to_update.update_attribute(:next_ssr_id, protocol_to_update.next_ssr_id + 1)
            dest_ssr.save(validate: false)
            dest_ssr.update_org_tree
            ssr.service_request.ensure_ssr_ids
          end

          # Move li.
          li.update!(sub_service_request_id: dest_ssr.id)
        end
      end # ssr.line_items.each
    end

  end

  def merge_service(old_service_id, new_service_id)
    old_service = Service.find(old_service_id)
    new_service = Service.find(new_service_id)
    dest_org_process_ssrs = new_service.organization.process_ssrs_parent
    puts "Merging Service #{old_service.id} into #{new_service.id} belonging to Org ##{dest_org_process_ssrs.id}"

    [LineItem, ServiceProvider].each do |model|
      model.where(service_id: old_service_id).each do |obj|
        obj.update!(service_id: new_service_id)
      end
    end

    old_service.destroy
  end
end

