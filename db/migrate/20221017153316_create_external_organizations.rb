class CreateExternalOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :external_organizations do |t|
      t.string :collaborating_org_name
      t.string :collaborating_org_type
      t.text :comments

      t.timestamps
    end
  end
end
