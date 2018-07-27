desc "Move Investigational Drug Services Process SSRS"
task move_process_ssrs: :environment do

  def find_existing_ssr(protocol, org_id)
    ssrs = protocol.sub_service_requests.select {|ssr| ssr.organization_id == org_id }
    
    ssrs.first
  end

  new_process_ssr_orgs = Organization.find(150, 151, 152, 153, 155, 156)

  old_org = Organization.find 77
  old_org.update_attributes(process_ssrs: false)
  new_process_ssr_orgs.each do |org|
    org.update_attributes(process_ssrs: true)
  end
  sub_service_requests = SubServiceRequest.where(organization_id: 77)

  sub_service_requests.each do |ssr|
    puts "Dropping into request"
    protocol = ssr.protocol
    org_ids_used = []
    ssr.line_items.each do |line_item|
      unless (line_item.service.id == 2908) 
        org_id = line_item.service.organization_id

        if ssr.organization_id == 77 # take care of first line item
          puts "Updating first line item"
          org_ids_used << org_id
          ssr.update_attributes(organization_id: org_id)
        elsif org_ids_used.include?(org_id) && (org_id != ssr.organization.id) 
          puts "Assigning request to line item"
          assign_to_ssr = find_existing_ssr(protocol, org_id)
          line_item.update_attributes(sub_service_request_id: assign_to_ssr.id)
        else
          puts "Creating new request for line item"
          org_ids_used << org_id
          new_ssr = SubServiceRequest.new(service_request_id: ssr.service_request.id, organization_id: org_id,
                                          status: ssr.status, owner_id: ssr.owner_id, 
                                          ssr_id: (sprintf '%04d', protocol.next_ssr_id), org_tree_display: ssr.org_tree_display,
                                          service_requester_id: ssr.service_requester.id, submitted_at: ssr.submitted_at,
                                          protocol_id: protocol.id)
          new_ssr.save(validate: false)
          line_item.update_attributes(sub_service_request_id: new_ssr.id)
          protocol.update_attribute(:next_ssr_id, protocol.next_ssr_id + 1)
          new_ssr.update_org_tree
        end
      end
    end
  end 
end