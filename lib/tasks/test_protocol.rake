# TODO delete
task test_protocol: :environment do
  count = Protocol.count
  finished = 0
  Protocol.all.each do |p|
    finished += 1
    puts "#{finished}/#{count}"
    p = p.becomes(Protocol)
    if p.principal_investigators != p.principal_investigators2.to_a
      puts "protocol #{p.id}; principal_investigators"
      break
    end

    if p.billing_managers != p.billing_managers2.to_a
      puts "protocol #{p.id}; billing_managers"
      break
    end

    if p.coordinators != p.coordinators2.to_a
      puts "protocol #{p.id};coordinators  "
      break
    end

    if p.primary_pi_project_role != p.primary_pi_project_role2
      puts "protocol #{p.id};primary_pi_project_role  "
      break
    end

    if p.coordinator_emails != p.coordinator_emails2
      puts "protocol #{p.id};coordinator_emails  "
      break
    end

    if p.all_child_sub_service_requests != p.all_child_sub_service_requests2.to_a
      puts "protocol #{p.id};all_child_sub_service_requests  "
      break
    end

    if p.push_to_epic_in_progress? != p.push_to_epic_in_progress2?
      puts "protocol #{p.id};push_to_epic_in_progress "
      break
    end

    if p.push_to_epic_complete? != p.push_to_epic_complete2?
      puts "protocol #{p.id};push_to_epic_complete "
      break
    end

    if p.should_push_to_epic? != p.should_push_to_epic2?
      puts "protocol #{p.id};should_push_to_epic "
      break
    end

    if p.has_nexus_services? != p.has_nexus_services2?
      puts "protocol #{p.id};has_nexus_services "
      break
    end

    p.service_requests.each do |service_request|
      if p.find_sub_service_request_with_ctrc(service_request) != p.find_sub_service_request_with_ctrc2(service_request)
        puts "protocol #{p.id}; service_request #{service_request.id}; find_sub_service_request_with_ctrc "
        break
      end
      if p.direct_cost_total(service_request) != p.direct_cost_total2(service_request)
        puts "protocol #{p.id}; service_request #{service_request.id};direct_cost_total "
        break
      end

      if p.indirect_cost_total(service_request) != p.indirect_cost_total2(service_request)
        puts "protocol #{p.id}; service_request #{service_request.id};indirect_cost_total "
        break
      end

      if p.find_sub_service_request_with_ctrc(service_request) != p.find_sub_service_request_with_ctrc2(service_request)
        puts "protocol #{p.id}; service_request #{service_request.id}; find_sub_service_request_with_ctrc"
      end
    end

    if p.any_service_requests_to_display? != p.any_service_requests_to_display2?
      puts "protocol #{p.id};any_service_requests_to_display "
      break
    end


    p.primary_pi_exists
    e1 = p.errors
    p.primary_pi_exists2
    e2 = p.errors

    if e1 != e2
      puts "protocol #{p.id}; "
    end

    i = Identity.joins(:project_roles).where(project_roles: { protocol_id: p.id }).sample(1).first
    if p.role_for(i) != p.role_for2(i)
      puts "protocol #{p.id}; identity: #{i.id}; role_for"
      break
    end
    if p.role_for(Identity.first) != p.role_for2(Identity.first)
      puts "protocol #{p.id}; identity: 0; role_for"
    end

    if p.role_other_for(i) != p.role_other_for2(i)
      puts "protocol #{p.id}; identity: #{i.id}; role_other_for"
    end
    if p.role_other_for(Identity.first) != p.role_other_for(Identity.first)
      puts "protocol #{p.id}; identity: 0; role_other_for"
    end
  end
end
