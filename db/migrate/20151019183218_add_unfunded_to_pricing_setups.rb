class AddUnfundedToPricingSetups < ActiveRecord::Migration
  def change
    add_column :pricing_setups, :unfunded_rate_type, :string
  end
end
