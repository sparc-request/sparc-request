desc "Task for merging service requests under a protocol"
task :merge_service_requests => :environment do

  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  def merge_requests(service_requests)
    master_request = service_requests.shift
    puts 'The following requests are now empty and should be deleted:'
    service_requests.each do |request|
      assign_sub_service_requests(master_request, request)
      assign_line_items(master_request, request)
      puts "Service Request: #{request.id}"
    end
  end

  def assign_sub_service_requests(master_request, request)
    request.sub_service_requests.each do |ssr|
      ssr.update_attributes(service_request_id: master_request.id)
    end
  end

  def assign_line_items(master_request, request)
    request.line_items.each do |line_item|
      line_item.update_attributes(service_request_id: master_request.id)
    end 
  end

  puts 'This task will merge all service requests under a protocol.'
  protocol_id = prompt "Enter the ID of the protocol: "
  protocol = Protocol.find(protocol_id.to_i)

  if protocol.service_requests.size > 1
    service_requests = protocol.service_requests.order('updated_at DESC').to_a
    merge_requests(service_requests)
  else
    puts "This protocol does not have more than one service request."
  end
end