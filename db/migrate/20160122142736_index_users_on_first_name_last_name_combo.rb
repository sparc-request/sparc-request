class IndexUsersOnFirstNameLastNameCombo < ActiveRecord::Migration
  def change
    #TODO current testing, staging, production mysql implementations don't support FULLTEXT on InnoDB,  may come back to this in the future, only used in app/models/protocol.rb search_query scope
    #add_index :identities, [:first_name, :last_name], name: 'full_name', type: :fulltext
  end
end
