class AddApprovedToCoreIdentities < ActiveRecord::Migration[6.0]
  using(:master)

  def change
    add_column :identities, :approved, :boolean, default: false, null: false
    add_index :identities, :approved
  end
end
