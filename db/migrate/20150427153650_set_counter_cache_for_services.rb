class SetCounterCacheForServices < ActiveRecord::Migration
  def up
    services = Service.all

    services.each do |service|
      Service.update_counters(service.id, line_items_count: service.line_items.count)
    end
  end

  def down
    services = Service.all

    services.each do |service|
      Service.update_counters(service.id, line_items_count: 0)
    end
  end
end
