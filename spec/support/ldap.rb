require "#{Rails.root.join("lib/directory")}"

if not USE_LDAP then
  raise "LDAP is not enabled for the test environment.  Please enable it in config/application.yml (Don't worry, the tests won't try to connect to a real LDAP server, because they stub Net::LDAP with test data)."
end

def create_ldap_filter(term)
  fields = [Directory::LDAP_UID, Directory::LDAP_LAST_NAME, Directory::LDAP_FIRST_NAME, Directory::LDAP_EMAIL]
  return fields.map {|f| Net::LDAP::Filter.contains(f, term)}.inject(:|)
end

RSpec.configure do |config|

  config.before(:each) do 
    ldap = double(port: 636, base: 'ou=people,dc=musc,dc=edu', encryption: :simple_tls)
    results = [
      { "givenname" => ["Ash"], "sn" => ["Ketchum"], "mail" => ["ash@theverybest.com"], "uid" => ["ash151"] },
      { "givenname" => ["Ash"], "sn" => ["Williams"], "mail" => ["ash@s-mart.com"], "uid" => ["ashley"] },
      { "givenname" => ["No"], "sn" => ["Email"], "uid" => ["iamabadldaprecord"] },
      { "givenname" => ['Brian'], "sn" => ['Kelsey'], "uid" => ['bjk7'], "mail" => ['kelsey@musc.edu'] },
      { "givenname" => ['Jason'], "sn" => ['Leonard'], "uid" => ['jpl6@musc.edu'], "mail" => ['leonarjp@musc.edu'] },
      { "givenname" => ['Julia'], "sn" => ['Glenn'], "uid" => ['jug2'], "mail" => ['glennj@musc.edu'] },
    ]
    ldap.stub(:search).with(filter: create_ldap_filter('ash151')).and_return([results[0]])
    ldap.stub(:search).with(filter: create_ldap_filter('bjk7')).and_return([results[3]])
    ldap.stub(:search).with(filter: create_ldap_filter('leonarjp')).and_return([results[4]])
    ldap.stub(:search).with(filter: create_ldap_filter('Julia')).and_return([results[5]])
    ldap.stub(:search).with(filter: create_ldap_filter('ash')).and_return([results[0], results[1]])
    ldap.stub(:search).with(filter: create_ldap_filter('iamabadldaprecord')).and_return([results[2]])
    ldap.stub(:search).with(filter: create_ldap_filter('gary')).and_return([])
    ldap.stub(:search).with(filter: create_ldap_filter('error')).and_raise('error')
    ldap.stub(:search).with(filter: create_ldap_filter('duplicate')).and_return()
    Net::LDAP.stub(:new).and_return(ldap)
  end
end
