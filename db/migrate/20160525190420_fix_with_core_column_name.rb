class FixWithCoreColumnName < ActiveRecord::Migration
  def change
    rename_column :protocol_filters, :with_core, :with_organization
  end
end
