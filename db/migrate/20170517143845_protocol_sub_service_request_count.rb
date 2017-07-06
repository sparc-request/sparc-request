class ProtocolSubServiceRequestCount < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :protocols, :sub_service_requests_count, :integer, default: 0

    Protocol.reset_column_information

    Protocol.all.each do |protocol|
      Protocol.update_counters protocol.id, :sub_service_requests_count => protocol.sub_service_requests.count
    end
  end
end