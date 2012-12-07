class AddApprovedToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :approved, :boolean, :default => false, :null => false
    add_index :identities, :approved
  end
end
