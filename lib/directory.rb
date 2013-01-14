require 'net/ldap'

class Directory
  # TODO: needs to use config/application.yml for ldap config
  LDAP_HOST       = 'authldap.musc.edu'
  LDAP_PORT       = 636
  LDAP_BASE       = 'ou=people,dc=musc.edu,dc=edu'
  LDAP_ENCRYPTION = :simple_tls
  DOMAIN          = 'musc.edu'

  # Searches LDAP and the database for a given search string (can be
  # ldap_uid, last_name, first_name, email).  If an identity is found in
  # LDAP that is not in the database, an Identity is created for it.
  # Returns an array of Identities that match the query.
  def self.search(term)
    # Search ldap and the database
    ldap_results = search_ldap(term)

    # If there are any entries returned from ldap that were not in the
    # database, then create them
    create_or_update_database_from_ldap(ldap_results)

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

  def ldap_to_common_form(r)
    {
      first_name: r.givenname.first.downcase,
      last_name:  r.sn.first.downcase,
      email:      r.mail.first.downcase,
      uid:        "#{r.uid.first.downcase}@#{DOMAIN}",
    }
  end

  def db_to_common_form(i)
    {
      first_name: i.first_name.downcase,
      last_name:  i.last_name.downcase,
      email:      i.email.downcase,
      uid:        i.ldap_uid.downcase,
    }
  end

  # Create a new identity for from each element of the given array.
  # Expects the entry to be an object as would be returned from
  # ldap_entries_not_in_database().
  def self.create_or_update_database_from_ldap(ldap_results)
    # Any users that are in the LDAP results but not the database results, should have
    # a database entry created for them.
    ldap_results.each do |r|
      # since we auto create we need to set a random password and auto confirm the addition so that the user has immediate access
      begin
        uid         = "#{r.uid.first.downcase}@#{DOMAIN}"
        email       = r.mail.first
        first_name  = r.givenname.first
        last_name   = r.sn.first

        # TODO: This might turn out to be too slow.  Will it need to be
        # optimized?  In particular, if there are a lot of results from
        # ldap, then this will result in a lot of queries to the
        # database.

        # Check to see if the identity is already in the database
        if (identity = Identity.find_by_ldap_uid(uid)) then

          # Do we need to update any of the fields?  Has someone's last
          # name changed due to getting married, etc.?
          if identity.email != email or
             identity.last_name != last_name or
             identity.first_name != first_name then

            identity.update_attributes!(
                email: email,
                first_name: first_name,
                last_name: last_name)
          end

        # if it is not, then added it
        else

          # TODO: using capitalize will not work for McHenry, e.g.
          Identity.create!(
              first_name: first_name,
              last_name:  last_name,
              email:      email,
              ldap_uid:   uid,
              password:   Devise.friendly_token[0,20],
              approved:   true)

        end

      rescue ActiveRecord::ActiveRecordError => e
        # TODO: rescuing this exception means that an email will not get
        # sent.  This may or may not be the behavior that we want, but
        # it is the existing behavior.
        Rails.logger.info '#'*100
        Rails.logger.info "#{e.message} (#{e.class})"
        Rails.logger.info e.backtrace.first(20)
        Rails.logger.info '#'*100
      end
    end
  end
end

