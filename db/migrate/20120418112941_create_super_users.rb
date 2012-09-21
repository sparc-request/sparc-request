class CreateSuperUsers < ActiveRecord::Migration
  def change
    create_table :super_users do |t|
      t.integer :identity_id
      t.integer :organization_id

      t.timestamps
    end

    add_index :super_users, :organization_id
  end
end
