class ChangeLdapBaseSettingToJson < ActiveRecord::Migration[5.1]
  def up
    Setting.where(key: 'ldap_base').each do |setting|
      setting.update_attributes(data_type: 'json', value: "[\"#{setting.read_attribute(:value)}\"]")
    end
  end

  def down
    Setting.where(key: 'ldap_base').each do |setting|
      setting.update_attributes(data_type: 'string', value: setting.value.first)
    end
  end
end
