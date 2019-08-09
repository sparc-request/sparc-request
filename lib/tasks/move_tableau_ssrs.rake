task move_tableau_data: :environment do

  service = Service.find 37990
  line_items = LineItem.where(service_id: service.id)

  service.organization_id = 311
  service.save(validate: false)

  line_items.each do |item|
    ssr = item.sub_service_request
    protocol = ssr.protocol

    if ssr.line_items.size > 1

      new_ssr = SubServiceRequest.new(service_request_id: ssr.service_request.id, organization_id: ssr.organization.id,
                                              status: ssr.status, owner_id: ssr.owner_id, 
                                              ssr_id: (sprintf '%04d', protocol.next_ssr_id), org_tree_display: ssr.org_tree_display,
                                              service_requester_id: ssr.service_requester.id, submitted_at: ssr.submitted_at,
                                              protocol_id: protocol.id, in_work_fulfillment: ssr.in_work_fulfillment)

      ssr.line_items.each do |item|
        if (item.service.id != 37990) && (new_ssr.id == nil) #Take care of first line item that isn't under 37990
          new_ssr.save(validate: false) #now the new_ssr's id is no longer nil
          item.sub_service_request_id = new_ssr.id
          item.save(validate: false)
        elsif (item.service.id != 37990) #Take care of all subsequent item that isn't under 37990
          item.sub_service_request_id = new_ssr.id
          item.save(validate: false)
        else
          item.sub_service_request.organization_id = 311
          item.sub_service_request.save(validate: false)
        end
      end
    else
      ssr.organization_id = 311
      ssr.save(validate: false)
    end
  end
end