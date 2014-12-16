class AddRevenueCodeRangeIdToService < ActiveRecord::Migration
  def change
    add_column :services, :revenue_code_range_id, :integer
  end
end
