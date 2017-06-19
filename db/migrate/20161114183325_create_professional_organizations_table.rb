class CreateProfessionalOrganizationsTable < ActiveRecord::Migration[4.2]
  def up
    create_table :professional_organizations do |t|
      t.text :name
      t.string :org_type
      t.integer :parent_id
    end

    add_column :identities, :professional_organization_id, :integer
  end

  def down
    drop_table :professional_organizations
    remove_column :identities, :professional_organization_id
  end
end
