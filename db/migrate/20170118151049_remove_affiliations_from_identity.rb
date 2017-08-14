class RemoveAffiliationsFromIdentity < ActiveRecord::Migration[4.2]
  def up
    Rake::Task['match_identity_with_professional_organization'].invoke
    remove_column :identities, :institution
    remove_column :identities, :college
    remove_column :identities, :department
  end

  def down
    add_column :identities, :institution, :string
    add_column :identities, :college,     :string
    add_column :identities, :department,  :string
  end
end
