class AddDeletedAtToPricingSetupsAndServiceProviders < ActiveRecord::Migration
  def change
    add_column :pricing_setups, :deleted_at, :datetime
    add_column :service_providers, :deleted_at, :datetime
  end
end
