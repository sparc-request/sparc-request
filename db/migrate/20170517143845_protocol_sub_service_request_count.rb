class ProtocolSubServiceRequestCount < ActiveRecord::Migration[5.0]
  def change
    add_column :protocols, :has_ssrs, :integer, default: 0

    Protocol.all.each do |protocol|
      has_ssrs = protocol.sub_service_requests.count > 0 ? 1 : 0
      protocol.update_attribute(:has_ssrs, has_ssrs)
    end
  end
end
