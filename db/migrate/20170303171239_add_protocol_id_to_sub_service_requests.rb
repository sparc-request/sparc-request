class AddProtocolIdToSubServiceRequests < ActiveRecord::Migration
  def change
    add_column :sub_service_requests, :protocol_id, :integer

    SubServiceRequest.find_each do |ssr|
      if ssr.service_request
        if ssr.service_request.protocol_id
          ssr.protocol_id = ssr.service_request.protocol_id
          ssr.save
        else
          puts "Sub Service Request: #{ssr.id} has a Service Request with no protocol_id"
        end
      else
        puts "Sub Service Request: #{ssr.id} has no Service Request"
      end
    end

  end
end
