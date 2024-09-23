class InsertSystemAdminIntoDatabase < ActiveRecord::Migration[6.1]
  def change
    Identity.create(ldap_uid: 'sparc_system_admin@musc.edu', first_name: 'System', last_name: 'Admin', system_admin: true, password: SecureRandom.hex(13), email: 'random_fake_email@musc.edu')
  end
end
