class AutoRunLdapAndEpicImportRakes < ActiveRecord::Migration[5.1]
  require 'rake'
  def up
    SettingsPopulator.new().populate
  end
  def down
    Setting.where(group: 'ldap_settings').destroy_all
    Setting.where(group: 'epic_settings').destroy_all
  end
end
