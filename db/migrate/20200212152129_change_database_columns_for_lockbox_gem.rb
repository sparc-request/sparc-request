class ChangeDatabaseColumnsForLockboxGem < ActiveRecord::Migration[6.0]
  using(:master)

  def change
    add_column :databases, :name_ciphertext,      :string, after: :university_id
    add_column :databases, :host_ciphertext,      :string, after: :name_ciphertext
    add_column :databases, :username_ciphertext,  :string, after: :host_ciphertext
    add_column :databases, :password_ciphertext,  :string, after: :username_ciphertext

    remove_column :databases, :encrypted_name
    remove_column :databases, :encrypted_name_iv
    remove_column :databases, :encrypted_username
    remove_column :databases, :encrypted_username_iv
    remove_column :databases, :encrypted_host
    remove_column :databases, :encrypted_host_iv
    remove_column :databases, :encrypted_password
    remove_column :databases, :encrypted_password_iv
  end
end
