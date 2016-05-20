class ChangeProtocolFilterForAdminToWithSsrFilter < ActiveRecord::Migration
	def up
		remove_column :protocol_filters, :for_admin
		add_column    :protocol_filters, :for_admin_with_filter, :integer
	end

	def down
		remove_column :protocol_filters, :for_admin_with_filter
		add_column    :protocol_filters, :for_admin, :integer
	end
end
