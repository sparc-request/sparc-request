class RemoveIsOneTimeFeeFromLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :is_one_time_fee
  end
end
