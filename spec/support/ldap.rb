require "#{Rails.root.join("lib/directory")}"

if not USE_LDAP then
  raise "LDAP is not enabled for the test environment.  Please enable it in config/application.yml (Don't worry, the tests won't try to connect to a real LDAP server, because they stub Net::LDAP with test data)."
end

def create_ldap_filter(term)
  fields = [Directory::LDAP_UID, Directory::LDAP_LAST_NAME, Directory::LDAP_FIRST_NAME, Directory::LDAP_EMAIL]
  return fields.map {|f| Net::LDAP::Filter.contains(f, term)}.inject(:|)
end

