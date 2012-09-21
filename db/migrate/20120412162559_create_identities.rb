class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :ldap_uid
      t.string :obisid
      t.string :email
      t.string :last_name
      t.string :first_name
      t.string :institution
      t.string :college
      t.string :department
      t.string :era_commons_name
      t.string :credentials
      t.string :subspecialty
      t.string :phone

      t.timestamps
    end

    add_index :identities, :ldap_uid
    add_index :identities, :obisid
    add_index :identities, :last_name
    add_index :identities, :email
  end
end