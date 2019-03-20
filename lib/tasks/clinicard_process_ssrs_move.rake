task clincard_process_ssrs_move: :environment do

  org_id = 211 # Old split/notify organization
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
    
    ssr.line_items.each do |item|
      puts "Line item #{count}'s organization: #{item.service.organization_id}"
      count += 1
    end
    puts "-"*20
  end

  single_ssrs.each do |ssr|
    org_id = ssr.line_items.first.service.organization_id
    ssr.organzation_id = org_id
    ssr.save(validate: false)
  end
end
