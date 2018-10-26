class AddOrcidToIdentities < ActiveRecord::Migration[5.2]
  def up
    add_column :identities, :orcid, "char(19)"
  end

  def down
    remove_column :identities, :orcid
  end
end
