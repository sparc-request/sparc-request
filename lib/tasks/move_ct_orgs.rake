desc "Move ct.gov services underneath a new organization"
task move_ct_orgs: :environment do

  def create_new_request(ssr)
    first = true
    protocol = ssr.protocol
    ssr.line_items.each do |li|
      if (!first && li.service.organization_id == 284)
        puts "*" * 20
        puts "Creating new ssr"
        puts protocol.inspect
        puts ssr.inspect
        puts "* * 20"
        new_ssr = SubServiceRequest.new(service_request_id: ssr.service_request.id, organization_id: 284,
                                            status: ssr.status, owner_id: ssr.owner_id, 
                                            ssr_id: (sprintf '%04d', protocol.next_ssr_id), org_tree_display: ssr.org_tree_display,
                                            service_requester_id: ssr.service_requester.id, submitted_at: ssr.submitted_at,
                                            protocol_id: protocol.id, in_work_fulfillment: 0)
        new_ssr.save(validate: false)
        li.update_attributes(sub_service_request_id: new_ssr.id)
        protocol.update_attribute(:next_ssr_id, protocol.next_ssr_id + 1)
        new_ssr.update_org_tree
      else
        first = false
      end
    end
  end

  services = Service.find(199, 8288, 37725)
  # sub_service_requests = []

  services.each do |service|
    puts "Updating service #{service.id}"
    service.update_attributes(organization_id: 284)
    service.line_items.each do |line_item|
      ssr = line_item.sub_service_request
      first = true
      if ssr.line_items.count > 1
        create_new_request(ssr)
      else
        puts "Updating line item #{line_item.id} and ssr #{line_item.sub_service_request_id}"
        line_item.sub_service_request.update_attributes(organization_id: 284)
      end
    end
  end
end