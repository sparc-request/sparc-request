class AddScopusIdToIdentity < ActiveRecord::Migration[7.0]
  def change
    add_column :identities, :scopus_id, 'char(11)', after: :orcid
  end
end
