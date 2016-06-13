class ConsolidateAdminProtocolFilters < ActiveRecord::Migration
  def change
    add_column :protocol_filters, :admin_filter, :string
    remove_column :protocol_filters, :for_identity_id
    remove_column :protocol_filters, :filtered_for_admin
  end
end
