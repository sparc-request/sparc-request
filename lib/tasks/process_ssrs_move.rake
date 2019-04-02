task process_ssrs_move: :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  puts "This task will move sub service requests created under a split/notify"
  puts "organization and place them under child split/notify organizations,"
  puts "given that the services have already been moved to their proper split/"
  puts "notify."

  id = prompt "Enter the id of the old split/notify organization: "

  org_id = id.to_i # Old split/notify organization
  old_org = Organization.find org_id
  old_org.process_ssrs = false # Fix the main problem. Split/notify is now on the child orgs 
  old_org.save(validate: false)
  
  # Grab all the sub service request that are under the old split/notify 
  # organization. 
  ssrs = SubServiceRequest.where(organization_id: org_id)

  # Separate out the ssrs. Ssrs that only have one line item are much easier to 
  # deal with. You just change the ssr's organization id to whatever the line item's
  # service organization is. Ssrs with more than one line item must be dealt with
  # in a more complex manner
  big_ssrs = []
  single_ssrs = []
  touched_ssrs = []
  created_ssrs = []

  ssrs.each do |ssr|
    if ssr.line_items.count > 1
      big_ssrs << ssr
    else
      single_ssrs << ssr
    end
  end

  big_ssrs.each do |ssr|
    # Set the master org id. All line items belonging to a service with this org id
    # will stay with the original ssr and don't have to be touched
    org_id = ssr.line_items.first.service.organization_id
    ssr.organization_id = org_id
    ssr.save(validate: false)
    protocol = Protocol.find(ssr.protocol_id)

    # We have to keep track of what org ids we have already used in order to decide
    # whether to create a new ssr or assign a line item to one we've already created
    used_org_ids = []

    ssr.line_items.each do |item|
      line_item_org_id = item.service.organization_id
      # If it's not the master org id, create a new
      # ssr or assign to newly created ssr
      if (line_item_org_id != org_id)
        touched_ssrs << ssr.id
        # We haven't used this org id yet, so create a new ssr
        if !used_org_ids.include?(line_item_org_id)
          puts "Creating new ssr"
          used_org_ids << line_item_org_id # All future line items with this org id will be assigned to this ssr
          new_ssr = SubServiceRequest.new(service_request_id: ssr.service_request.id, organization_id: line_item_org_id,
                                              status: ssr.status, owner_id: ssr.owner_id, 
                                              ssr_id: (sprintf '%04d', protocol.next_ssr_id), org_tree_display: ssr.org_tree_display,
                                              service_requester_id: ssr.service_requester.id, submitted_at: ssr.submitted_at,
                                              protocol_id: protocol.id, in_work_fulfillment: ssr.in_work_fulfillment)
          new_ssr.save(validate: false)
          item.update_attributes(sub_service_request_id: new_ssr.id)
          protocol.next_ssr_id = protocol.next_ssr_id + 1
          protocol.save(validate: false)
          new_ssr.update_org_tree
          created_ssrs << new_ssr.id
        else
          # This org id is in the used array, meaning an ssr has already been created.
          # All we have to do is assign this line item to that ssr.
          puts "Assigning to ssr"
          existing_ssr = SubServiceRequest.where(organization_id: line_item_org_id).last
          item.update_attributes(sub_service_request_id: existing_ssr.id)
        end
      end
    end
  end

  # Dealing with the easy ones. Just simply assigning the org id
  single_ssrs.each do |ssr|
    org_id = ssr.line_items.first.service.organization_id
    ssr.organization_id = org_id
    ssr.save(validate: false)
  end

  puts "Ssrs affected by script:"
  puts touched_ssrs
  puts ""
  puts "Newly created ssrs:"
  puts created_ssrs
end
