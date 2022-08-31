class AddDemographicInfoToIdentities < ActiveRecord::Migration[4.2]
  def change
    add_column :identities, :age_group, :string
    add_column :identities, :gender, :string
    add_column :identities, :race, :string
  end
end
