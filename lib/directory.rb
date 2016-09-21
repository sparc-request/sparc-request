# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'net/ldap'

class Directory
  # Only initialize LDAP if it is enabled
  if USE_LDAP
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
      LDAP_AUTH_USERNAME      = ldap_config['ldap_auth_username']
      LDAP_AUTH_PASSWORD      = ldap_config['ldap_auth_password']
      LDAP_FILTER      = ldap_config['ldap_filter']
    rescue
      raise "ldap.yml not found, see config/ldap.yml.example"
    end
  end

  # Searches LDAP and the database for a given search string (can be
  # ldap_uid, last_name, first_name, email).  If an identity is found in
  # LDAP that is not in the database, an Identity is created for it.
  # Returns an array of Identities that match the query.
  def self.search(term)
    # Search ldap (if enabled) and the database
    if USE_LDAP && !SUPPRESS_LDAP_FOR_USER_SEARCH
      ldap_results = search_ldap(term)
      db_results = search_database(term)
      # If there are any entries returned from ldap that were not in the
      # database, then create them
      create_or_update_database_from_ldap(ldap_results, db_results)
      # Finally, search the database a second time and return the results.
      # If there were no new identities created, then this should return
      # the same as the original call to search_database().
      return search_database(term)
    else # only search database once
      return search_database(term)
    end
  end

  # Searches the database only for a given search string.  Returns an
  # array of Identities.
  def self.search_database(term)
    search_query = query(term)
    identities = Identity.find_by_sql(search_query)
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
      ldap.auth LDAP_AUTH_USERNAME, LDAP_AUTH_PASSWORD unless !LDAP_AUTH_USERNAME || !LDAP_AUTH_PASSWORD
      # use LDAP_FILTER to override default filter with custom string
      filter = (LDAP_FILTER && LDAP_FILTER.gsub('#{term}', term)) || fields.map { |f| Net::LDAP::Filter.contains(f, term) }.inject(:|)
      res = ldap.search(:attributes => fields, :filter => filter)
      Rails.logger.info ldap.get_operation_result unless res
    rescue => e
      Rails.logger.info '#'*100
      Rails.logger.info "#{e.message} (#{e.class})"
      Rails.logger.info '#'*100
      res = nil
    end

    return res
  end

  # SQL query that returns identities
  def self.query(term)
    query_select     = "select distinct identities.* from identities"

    where_term = lambda do |search_term|
      return  "(identities.ldap_uid like \"%#{search_term}%\" or "\
              "identities.email like \"%#{search_term}%\" or "\
              "identities.first_name like \"%#{search_term}%\" or "\
              "identities.last_name like \"%#{search_term}%\")"
    end

    query_where = "where "
    search_terms = term.strip.split
    search_terms.each do |search_term|
      query_where += " and " unless search_term == search_terms.first
      query_where += where_term.call(search_term)
    end

    return query_select + ' ' + query_where
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
        uid         = "#{r[LDAP_UID].try(:first).try(:downcase)}@#{DOMAIN}"
        email       = r[LDAP_EMAIL].try(:first)
        first_name  = r[LDAP_FIRST_NAME].try(:first)
        last_name   = r[LDAP_LAST_NAME].try(:first)

        # Check to see if the identity is already in the database
        if (identity = identities[uid]) or (identity = Identity.find_by_ldap_uid uid) then
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
  
  # search and merge results but don't change the database
  # this assumes USE_LDAP = true, otherwise you wouldn't use this function
  def self.search_and_merge_ldap_and_database_results(term)
    results = []
    database_results = Directory.search_database(term)
    # This is an optimization so we only have to go to the database once
    identities = { }
    database_results.each do |identity|
      identities[identity.ldap_uid] = identity
    end
    ldap_results = Directory.search_ldap(term)
    ldap_results.each do |ldap_result|
      uid = "#{ldap_result[LDAP_UID].try(:first).try(:downcase)}@#{DOMAIN}"
      if identities[uid]
        results << identities[uid]
      else 
        email = ldap_result[LDAP_EMAIL].try(:first)
        if email && email.strip.length > 0 # all SPARC users must have an email, this filters out some of the inactive LDAP users.
          results << Identity.new(ldap_uid: uid, first_name: ldap_result[LDAP_FIRST_NAME].try(:first), last_name: ldap_result[LDAP_LAST_NAME].try(:first), email: email)
        end  
      end
    end
    results
  end
end
