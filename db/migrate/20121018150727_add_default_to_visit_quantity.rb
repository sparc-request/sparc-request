class AddDefaultToVisitQuantity < ActiveRecord::Migration
  def change
    change_column :visits, :quantity, :integer, :default => 0
    change_column :visits, :research_billing_qty, :integer, :default => 0
    change_column :visits, :insurance_billing_qty, :integer, :default => 0
    change_column :visits, :effort_billing_qty, :integer, :default => 0
  end
end
