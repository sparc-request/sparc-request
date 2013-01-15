class AddIsCtrcColumnToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_ctrc, :boolean, :default => false
  end
end
