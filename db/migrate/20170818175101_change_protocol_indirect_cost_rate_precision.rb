class ChangeProtocolIndirectCostRatePrecision < ActiveRecord::Migration[5.1]
  def change
    change_column :protocols, :indirect_cost_rate, :decimal, precision: 6, scale: 2
  end
end
