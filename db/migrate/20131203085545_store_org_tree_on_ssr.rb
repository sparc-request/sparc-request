class StoreOrgTreeOnSsr < ActiveRecord::Migration
  def up
    add_column :sub_service_requests, :org_tree_display, :text
  end

  def down
    remove_column :sub_service_requests, :org_tree_display
  end
end
