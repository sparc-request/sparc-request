class CreateDatabases < ActiveRecord::Migration[6.0]
  using(:master)

  def change
    create_table :databases do |t|
      t.references :university

      t.string :encrypted_name
      t.string :encrypted_name_iv
      t.string :encrypted_username
      t.string :encrypted_username_iv
      t.string :encrypted_host
      t.string :encrypted_host_iv
      t.string :encrypted_password
      t.string :encrypted_password_iv

      t.timestamps
    end
  end
end
