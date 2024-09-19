class CreateSystemAdminIdentity < ActiveRecord::Migration[6.1]
  def change
    add_column :identities, :system_admin, :boolean

    Identity.create(ldap_uid: 'sparc_system_admin@musc.edu', first_name: 'System', last_name: 'Admin', system_admin: true, password: SecureRandom.hex(13), email: 'random_fake_email@musc.edu')
  end
end
