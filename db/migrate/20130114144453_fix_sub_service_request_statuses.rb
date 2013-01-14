class FixSubServiceRequestStatuses < ActiveRecord::Migration
  def up
    SubServiceRequest.all.each do |ssr|
      if ssr.status.nil?
        ssr.update_attributes({:status => ssr.service_request.status})
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
