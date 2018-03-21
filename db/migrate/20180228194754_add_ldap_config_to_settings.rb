class AddLdapConfigToSettings < ActiveRecord::Migration[5.1]
  def up
    host_setting       = Setting.create key: 'ldap_host', value: nil, data_type: 'string', friendly_name: 'LDAP host name (eg. ldap.myhost.com)', description: 'Fully qualified hostname of the LDAP server'
    port_setting       = Setting.create key: 'ldap_port', value: nil, data_type: 'string', friendly_name: 'LDAP port (eg. 636)', description: 'LDAP server port'
    base_setting       = Setting.create key: 'ldap_base', value: nil, data_type: 'string', friendly_name: 'LDAP base DN', description: 'Base DN to use when searching LDAP'
    encryption_setting = Setting.create key: 'ldap_encryption', value: nil, data_type: 'string', friendly_name: 'LDAP encryption', description: 'Encryption type to use, simple_tls or start_tls'
    domain_setting     = Setting.create key: 'ldap_domain', value: nil, data_type: 'string', friendly_name: 'Domain appended to LDAP results (eg. myhost.com)', description: 'Domain appended to LDAP results to created institutional ldap_uids in the identities table (change my_uid to my_uid@myhost.com)'
    uid_setting        = Setting.create key: 'ldap_uid', value: nil, data_type: 'string', friendly_name: 'LDAP uid attribute (eg: cn)', description: 'LDAP uid attribute'
    last_name_setting  = Setting.create key: 'ldap_last_name', value: nil, data_type: 'string', friendly_name: 'LDAP last name attribute (eg: sn)', description: 'LDAP last name attribute'
    first_name_setting = Setting.create key: 'ldap_first_name', value: nil, data_type: 'string', friendly_name: 'LDAP first name attribute (eg: givenname)', description: 'LDAP first name attribute'
    email_setting      = Setting.create key: 'ldap_email', value: nil, data_type: 'string', friendly_name: 'LDAP email attribute (eg: mail)', description: 'LDAP email attribute'
    username_setting   = Setting.create key: 'ldap_auth_username', value: nil, data_type: 'string', friendly_name: 'Username used to authenticate to LDAP with', description: 'Username used to authenticate to LDAP with'
    password_setting   = Setting.create key: 'ldap_auth_password', value: nil, data_type: 'string', friendly_name: 'Password used to authenticate to LDAP with', description: 'Password used to authenticate to LDAP with'
    filter_setting     = Setting.create key: 'ldap_filter', value: nil,  data_type: 'string', friendly_name: 'Custom LDAP filter used in searching', description: 'Custom LDAP filter used in searching (eg. (&(|(|(|(cn=#{term}*)(sn=#{term}*))(givenName=#{term}*))(mail=#{term}*))(msRTCSIP-UserEnabled=TRUE)))'

    if Setting.find_by_key("use_ldap").value && Rails.env != 'test'
      begin
        ldap_config   ||= YAML.load_file(Rails.root.join('config', 'ldap.yml'))[Rails.env]
        ldap_host       = ldap_config['ldap_host']
        ldap_port       = ldap_config['ldap_port']
        ldap_base       = ldap_config['ldap_base']
        ldap_encryption = ldap_config['ldap_encryption'].to_sym
        ldap_domain          = ldap_config['ldap_domain']
        ldap_uid        = ldap_config['ldap_uid']
        ldap_last_name  = ldap_config['ldap_last_name']
        ldap_first_name = ldap_config['ldap_first_name']
        ldap_email      = ldap_config['ldap_email']
        ldap_auth_username      = ldap_config['ldap_auth_username']
        ldap_auth_password      = ldap_config['ldap_auth_password']
        ldap_filter      = ldap_config['ldap_filter']

        host_setting.update_attribute :value, ldap_host
        port_setting.update_attribute :value, ldap_port
        base_setting.update_attribute :value, ldap_base
        encryption_setting.update_attribute :value, ldap_encryption
        domain_setting.update_attribute :value, ldap_domain
        uid_setting.update_attribute :value, ldap_uid
        last_name_setting.update_attribute :value, ldap_last_name
        first_name_setting.update_attribute :value, ldap_first_name
        email_setting.update_attribute :value, ldap_email
        username_setting.update_attribute :value, ldap_auth_username
        password_setting.update_attribute :value, ldap_auth_password
        filter_setting.update_attribute :value, ldap_filter
      rescue
        raise "ldap.yml not found, see config/ldap.yml.example"
      end
    end
  end

  def down
    Setting.where(key: ['ldap_host', 'ldap_port', 'ldap_base', 'ldap_encryption', 'ldap_domain', 'ldap_uid', 'ldap_last_name', 'ldap_first_name', 'ldap_email', 'ldap_auth_username', 'ldap_auth_password', 'ldap_filter']).destroy_all
  end
end
