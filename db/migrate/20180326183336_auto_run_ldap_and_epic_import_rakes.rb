class AutoRunLdapAndEpicImportRakes < ActiveRecord::Migration[5.1]
  require 'rake'
  def up
    SettingsPopulator.new().populate
  end
  def down
    Setting.where(group: 'ldap_settings').where.not(
      key: ['lazy_load_ldap', 'suppress_ldap_for_user_search', 'use_ldap']
    ).destroy_all

    Setting.where(group: 'epic_settings').where.not(key:
      ['approve_epic_rights_mail_to', 'epic_queue_access', 'epic_queue_report_to', 'queue_epic', 'queue_epic_load_error_to', 'use_epic']
    ).destroy_all
  end
end
