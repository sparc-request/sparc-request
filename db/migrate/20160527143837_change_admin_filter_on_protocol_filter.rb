class ChangeAdminFilterOnProtocolFilter < ActiveRecord::Migration
  def up
    remove_column :protocol_filters, :for_admin
    add_column :protocol_filters, :filtered_for_admin, :integer
  end

  def down
    remove_column :protocol_filters, :filtered_for_admin
    add_column :protocol_filters, :for_admin, :integer
  end
end
