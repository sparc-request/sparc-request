require "#{Rails.root.join("lib/directory")}"
def create_ldap_filter(term)
  fields = [Directory::LDAP_UID, Directory::LDAP_LAST_NAME, Directory::LDAP_FIRST_NAME, Directory::LDAP_EMAIL]
  return fields.map {|f| Net::LDAP::Filter.contains(f, term)}.inject(:|)
end

