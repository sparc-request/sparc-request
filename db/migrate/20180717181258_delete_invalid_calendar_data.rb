class DeleteInvalidCalendarData < ActiveRecord::Migration[5.2]
  def change
    Protocol.joins(:arms).each do |protocol|
      unless protocol.line_items.joins(:service).where(services: { one_time_fee: false }).any?
        protocol.arms.destroy_all
      end
    end
  end
end
