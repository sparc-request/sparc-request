class AddOrcidToCoreIdentities < ActiveRecord::Migration[6.0]
  using(:master)

  def change
    add_column :identities, :orcid, "char(19)"
  end
end
