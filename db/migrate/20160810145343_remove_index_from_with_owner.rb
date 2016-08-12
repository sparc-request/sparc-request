class RemoveIndexFromWithOwner < ActiveRecord::Migration
  def change
    remove_index :protocol_filters, :with_owner
  end
end
