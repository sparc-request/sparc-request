class RemoveAffiliationsFromIdentity < ActiveRecord::Migration
  def up
    #remove_column :identities, :institution
    #remove_column :identities, :college
    #remove_column :identities, :department
  end

  def down
    #add_column :identities, :institution, :string
    #add_column :identities, :college,     :string
    #add_column :identities, :department,  :string
  end
end
