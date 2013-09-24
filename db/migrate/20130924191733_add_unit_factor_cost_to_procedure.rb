class AddUnitFactorCostToProcedure < ActiveRecord::Migration
  def change
    add_column :procedures, :unit_factor_cost, :decimal, :precision => 12, :scale => 4
  end
end
