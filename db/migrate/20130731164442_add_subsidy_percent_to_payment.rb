class AddSubsidyPercentToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :percent_subsidy, :float
  end
end
