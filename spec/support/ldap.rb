def create_ldap_filter(term)
  fields = %w(uid surName givenname mail)
  return fields.map {|f| Net::LDAP::Filter.contains(f, term)}.inject(:|)
end

