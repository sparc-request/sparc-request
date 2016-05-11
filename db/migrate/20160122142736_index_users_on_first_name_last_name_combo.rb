class IndexUsersOnFirstNameLastNameCombo < ActiveRecord::Migration
  def change
    add_index :identities, [:first_name, :last_name], name: 'full_name', type: :fulltext
  end
end
