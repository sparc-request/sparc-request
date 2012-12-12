require 'net/ldap'

module LdapGateway
  FIELDS = %w(surName givenname mail)

  def self.convert_ldap_entry(entry)
    {:uid        => entry[:uid][0],
     :first_name => entry[:givenname][0],
     :last_name  => entry[:sn][0],
     :email      => entry[:mail][0]}
  end

  def self.search_for(term)
    ldap = Net::LDAP.new( :host => 'authldap.musc.edu', :port => 636, :base => 'ou=people,dc=musc,dc=edu', :encryption => :simple_tls)
    filter = FIELDS.map{|f| Net::LDAP::Filter.contains(f, term)}.inject(:|)
    res = ldap.search(:filter => filter)
    res.map!{|entry|self.convert_ldap_entry(entry)}
    res.reject!{|m| m[:uid].nil? or m[:uid].strip.empty?}
    res
  end
end

module EntityGateway
  def self.search_for_users(terms)
    terms = terms.split.map{|term|term + "*"}
    terms = terms.join " OR "
    results = JSON.parse RestClient.get(OBIS_COMMON_URL + "/obisentity/identities/search?q=" +URI.escape(terms))
    return [] if results.empty?
    entity_ids = results.sort_by{|x|x['score']}.map{|x|x['id']}
    # TODO: cache identities for faster response time (see below)
    JSON.parse RestClient.get(OBIS_COMMON_URL + "/obissimple/identities?OBISIDs=" + entity_ids.join(','))
  end

  # For each ldap result (as returned by the LdapGateway), either finds the corresponding
  # identity or creates one
  # TODO: cache identities for faster response time (see above)
  def self.identities_from_ldap_results(ldaps)
    # TODO: do these in parallel on separate threads? At least the final GET could be
    #       done in bulk
    ldaps.map do |ldap|
      resp = begin
          JSON.parse RestClient.get(OBIS_COMMON_URL + "/obisentity/identifiers/ldap_uid/#{ldap[:uid]}")
        rescue RestClient::ResourceNotFound => rnf
          nil
        end
      if(resp)
        EntityConverter::from_entity resp
      else
        new_entity = {
          :attributes => ldap,
          :identifiers => {
            :ldap_uid => ldap[:uid]
          }
        }
        resp = JSON.parse RestClient.post(OBIS_COMMON_URL + "/obisentity/identities", new_entity.to_json, :content_type => :json)
        obisid = resp['identifiers']['OBISID']
        # SimpleRestClient.get("identities/#{obisid}")
        JSON.parse(RestClient.get(OBIS_COMMON_URL + "/obissimple/identities?OBISIDs=#{obisid}")).first
      end
    end
  end

end
