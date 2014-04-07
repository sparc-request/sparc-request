task :create_juan => :environment do

  identity = Identity.create(:ldap_uid => 'juan', 
                             :email => 'juan@gmail.com', 
                             :last_name => 'Castillo', 
                             :first_name => 'Juan', 
                             :phone => '555-555-5555', 
                             :catalog_overlord => 1,
                             :password => 'password',
                             :password_confirmation => 'password',
                             :approved => 1 )
  identity.save

  CatalogManager.create(:identity_id => identity.id, :organization_id => 45, :edit_historic_data => 1)
  SuperUser.create(:identity_id => identity.id, :organization_id => 45)

end