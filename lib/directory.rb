require 'net/ldap'

class Directory
  # Load the YAML file for ldap configuration and set constants
  begin 
    ldap_config   ||= YAML.load_file(Rails.root.join('config', 'ldap.yml'))[Rails.env]
    LDAP_HOST       = ldap_config['ldap_host']
    LDAP_PORT       = ldap_config['ldap_port']
    LDAP_BASE       = ldap_config['ldap_base']
    LDAP_ENCRYPTION = ldap_config['ldap_encryption'].to_sym
    DOMAIN          = ldap_config['ldap_domain']
    LDAP_UID        = ldap_config['ldap_uid']
    LDAP_LAST_NAME  = ldap_config['ldap_last_name']
    LDAP_FIRST_NAME = ldap_config['ldap_first_name']
    LDAP_EMAIL      = ldap_config['ldap_email']
  rescue
    raise "ldap.yml not found, see config/ldap.yml.example"
  end

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
    create_or_update_database_from_ldap(ldap_results, db_results)

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
    # Set the search fields from the constants provided
    fields = [LDAP_UID, LDAP_LAST_NAME, LDAP_FIRST_NAME, LDAP_EMAIL]
   
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

  # Create or update the database based on what was returned from ldap.
  # ldap_results should be an array as would be returned from
  # search_ldap.  db_results should be an array as would be returned
  # from search_database.
  def self.create_or_update_database_from_ldap(ldap_results, db_results)
    # no need to proceed if ldap_results == nil or []
    return if ldap_results.blank?
    # This is an optimization so we only have to go to the database once
    identities = { }

    db_results.each do |identity|
      identities[identity.ldap_uid] = identity
    end

    ldap_results.each do |r|
      begin
        uid         = "#{r.send(LDAP_UID).first.downcase}@#{DOMAIN}"
        email       = r.send(LDAP_EMAIL).first
        first_name  = r.send(LDAP_FIRST_NAME).first
        last_name   = r.send(LDAP_LAST_NAME).first

        # Check to see if the identity is already in the database
        if (identity = identities[uid]) then
          # Do we need to update any of the fields?  Has someone's last
          # name changed due to getting married, etc.?
          if identity.email != email or
             identity.last_name != last_name or
             identity.first_name != first_name then

            identity.update_attributes!(
                email:      email,
                first_name: first_name,
                last_name:  last_name)
          end

        else
          # If it is not in the database already, then add it.
          #
          # Use what we got from ldap for first/last name.  We don't use
          # String#capitalize here because it does not work for names
          # like "McHenry".
          #
          # since we auto create we need to set a random password and auto
          # confirm the addition so that the user has immediate access
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

