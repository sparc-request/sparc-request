class AddWithOwnerToProtocolFilter < ActiveRecord::Migration
  def change
    add_column :protocol_filters, :with_owner, :string
    add_index :protocol_filters, :with_owner
  end
end
