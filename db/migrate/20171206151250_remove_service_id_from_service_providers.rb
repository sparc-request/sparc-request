class RemoveServiceIdFromServiceProviders < ActiveRecord::Migration[5.1]
  def change
    remove_column :service_providers, :service_id, :integer
  end
end
