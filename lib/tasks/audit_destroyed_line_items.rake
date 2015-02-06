namespace :data do
  desc "List out all destroyed line items for a given service and protocol id"
  task :audit_destroyed_line_items => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    protocol_id = prompt("Please enter a protocol_id: ")
    service_id = prompt("Please enter a service id: ")

    service_requests = ServiceRequest.where(:protocol_id => protocol_id.to_i)
    line_items = AuditRecovery.where("auditable_type = ? AND action = ?", "LineItem", "destroy")
    new_lis = []

    service_requests.each do |sr|
      sr.sub_service_requests.each do |ssr|
        line_items.each do |li|
          if (li[:audited_changes]["service_id"] == service_id.to_i) && (li[:audited_changes]["sub_service_request_id"] == ssr.id)
            new_lis << li
          end
        end
      end
    end

    new_lis.each do |li|
      deleter = Identity.find(li[:user_id])
      puts "Line item #{li[:auditable_id]} was deleted by #{deleter.full_name} on #{li[:created_at]}"
    end
  end
end
