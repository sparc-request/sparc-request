class AddProtocolIdToSubServiceRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_service_requests, :protocol_id, :integer
    add_index :sub_service_requests, :protocol_id

    SubServiceRequest.reset_column_information
    SubServiceRequest.find_each do |ssr|
      if ssr.service_request
        if ssr.service_request.protocol_id
          ssr.update_attribute(:protocol_id, ssr.service_request.protocol_id)
        else
          puts "Sub Service Request: #{ssr.id} has a Service Request with no protocol_id"
        end
      else
        puts "Sub Service Request: #{ssr.id} has no Service Request"
      end
    end

  end
end
