class CreateProfessionalOrganizationsTable < ActiveRecord::Migration
  def up
    create_table :professional_organizations do |t|
      t.text :name
      t.string :org_type
      t.integer :parent_id
    end

    add_column :identities, :professional_organization_id, :integer
    remove_column :identities, :institution
    remove_column :identities, :college
    remove_column :identities, :department
  end

  def down
    drop_table :professional_organizations
    add_column :identities, :institution, :string
    add_column :identities, :college, :string
    add_column :identities, :department, :string
    remove_column :identities, :professional_organization_id
  end
end
