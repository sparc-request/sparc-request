class AutoRunLdapAndEpicImportRakes < ActiveRecord::Migration[5.1]
  require 'rake'
  def up
    Rake::Task["data:import_epic_yml"].invoke
    Rake::Task["data:import_ldap_yml"].invoke
  end
  def down
    settings = Setting.where(group: 'ldap_settings') + Setting.where(group: 'epic_settings')
    settings.destroy_all
  end
end
