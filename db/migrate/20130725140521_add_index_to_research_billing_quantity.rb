class AddIndexToResearchBillingQuantity < ActiveRecord::Migration
  def change
    add_index :visits, :research_billing_qty
  end
end
