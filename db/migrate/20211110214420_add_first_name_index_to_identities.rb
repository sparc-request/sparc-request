class AddFirstNameIndexToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_index :identities, :first_name
  end
end
