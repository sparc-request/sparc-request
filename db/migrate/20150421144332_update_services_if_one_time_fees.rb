class UpdateServicesIfOneTimeFees < ActiveRecord::Migration
  def up
    services = Service.all

    services.each do |service|
      if service.pricing_maps.last.is_one_time_fee
        service.update_attributes(one_time_fee: true)
      end
    end
  end

  def down
  end
end
