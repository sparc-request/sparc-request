class AddLbbFlagToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_column :identities, :imported_from_lbb, :boolean, :default => false
  end
end
