class SetNullTimeframeToMin < ActiveRecord::Migration
  def change
    null_timeframe_values = Fulfillment.where(timeframe: nil).where.not(time: nil)
    null_timeframe_values.each do |null_timeframe_value|
      null_timeframe_value.update_attribute(:timeframe, "Min")
    end
  end
end
