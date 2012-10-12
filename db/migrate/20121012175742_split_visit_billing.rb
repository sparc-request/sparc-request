class SplitVisitBilling < ActiveRecord::Migration
  def up
    add_column :visits, :research_billing_qty, :integer
    add_column :visits, :insurance_billing_qty, :integer
    add_column :visits, :effort_billing_qty, :integer
  end

  def down
  end
end
