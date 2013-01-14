require 'net/ldap'
require 'ostruct'

class Directory
  # TODO: needs to use config/application.yml for ldap config
  LDAP_HOST = 'authldap.musc.edu'
  LDAP_PORT = 636
  LDAP_BASE = 'ou=people,dc=musc.edu,dc=edu'
  LDAP_ENCRYPTION = :simple_tls

  # Searches LDAP and the database for a given search string (can be
  # ldap_uid, last_name, first_name, email).  If an identity is found in
  # LDAP that is not in the database, an Identity is created for it.
  # Returns an array of Identities that match the query.
  def self.search(term)
    # Search ldap and the database
    ldap_results = search_ldap(term)
    db_results = search_database(term)

    # If there are any entries returned from ldap that were not in the
    # database, then create them
    missing = ldap_entries_not_in_database(ldap_results, db_results)
    create_identities(missing)

    # Finally, search the database a second time and return the results.
    # If there were no new identities created, then this should return
    # the same as the original call to search_database().
    return search_database(term)
  end

  # Searches the database only for a given search string.  Returns an
  # array of Identities.
  def self.search_database(term)
    subqueries = [
      "ldap_uid LIKE '%#{term}%'",
      "email LIKE '%#{term}%'",
      "last_name LIKE '%#{term}%'",
      "first_name LIKE '%#{term}%'",
    ]
    query = subqueries.join(' OR ')
    identities = Identity.where(query)
    return identities
  end

  # Searches LDAP only for the given search string.  Returns an array of
  # Net::LDAP::Entry.
  def self.search_ldap(term)
    fields = %w(uid surName givenname mail)
   
    # query ldap and create new identities
    begin
      ldap = Net::LDAP.new(
          host: LDAP_HOST,
          port: LDAP_PORT,
          base: LDAP_BASE,
          encryption: LDAP_ENCRYPTION)
      filter = fields.map { |f| Net::LDAP::Filter.contains(f, term) }.inject(:|)
      res = ldap.search(:filter => filter)
    rescue => e
      Rails.logger.info '#'*100
      Rails.logger.info "#{e.message} (#{e.class})"
      Rails.logger.info '#'*100
      res = nil
    end

    return res
  end

  # Find LDAP entries that are not in the database.  Returns an array of
  # objects.
  def self.ldap_entries_not_in_database(ldap_results, db_results)
    if ldap_results.nil? # no results from ldap
      ldap_map = []
    else
      ldap_map = res.map { |r|
        {
          first_name: r.givenname.first.downcase,
          last_name:  r.sn.first.downcase,
          email:      r.mail.first.downcase,
          uid:        r.uid.first.downcase,
        }
      }
    end

    db_map = db_results.map { |i|
      {
        first_name: i.first_name.downcase,
        last_name:  i.last_name.downcase,
        email:      i.email.downcase,
        uid:        i.ldap_uid.downcase,
      }
    }

    difference = ldap_map - db_map
    return difference.map { |r| OpenStruct.new(r) }
  end

  # Create a new identity for from each element of the given array.
  # Expects the entry to be an object as would be returned from
  # ldap_entries_not_in_database().
  def self.create_identities(missing)
    # Any users that are in the LDAP results but not the database results, should have
    # a database entry created for them.
    missing.each do |new_identity|
      # TODO: needs to use config/application.yml for host config
      # since we auto create we need to set a random password and auto confirm the addition so that the user has immediate access
      begin
        Identity.create!(
            first_name: new_identity.first_name.capitalize,
            last_name:  new_identity.last_name.capitalize,
            email:      new_identity.email,
            ldap_uid:   new_identity.uid,
            password:   Devise.friendly_token[0,20],
            approved:   true)
      rescue ActiveRecord::ActiveRecordError => e
        Rails.logger.info '#'*100
        Rails.logger.info "#{e.message} (#{e.class})"
        Rails.logger.info e.backtrace.first(20)
        Rails.logger.info '#'*100
      end
    end
  end
end

