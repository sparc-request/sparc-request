class CreateExternalOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :external_organizations do |t|
      t.string :name
      t.string :type
      t.string :comments

      t.timestamps
    end
  end
end
