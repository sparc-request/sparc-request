class FixEpicAndLdapSettings < ActiveRecord::Migration[5.2]
  def up
    # Update keys
    if Setting.where(key: 'endpoint').any?
      Setting.find_by_key('endpoint').update_attribute(:key, 'epic_endpoint')
    end

    if Setting.where(key: 'namespace').any?
      Setting.find_by_key('namespace').update_attribute(:key, 'epic_namespace')
    end

    if Setting.where(key: 'study_root').any?
      Setting.find_by_key('study_root').update_attribute(:key, 'epic_study_root')
    end

    if Setting.where(key: 'test_mode').any?
      Setting.find_by_key('test_mode').update_attribute(:key, 'epic_test_mode')
    end

    if Setting.where(key: 'wsdl').any?
      Setting.find_by_key('wsdl').update_attribute(:key, 'epic_wsdl')
    end

    # Refresh other attributes (friendly name, description, group, etc)
    SettingsPopulator.new().populate
  end

  def down
    if Setting.where(key: 'epic_endpoint').any?
      Setting.find_by_key('epic_endpoint').update_attribute(:key, 'endpoint')
    end

    if Setting.where(key: 'epic_namespace').any?
      Setting.find_by_key('epic_namespace').update_attribute(:key, 'namespace')
    end

    if Setting.where(key: 'epic_study_root').any?
      Setting.find_by_key('epic_study_root').update_attribute(:key, 'study_root')
    end

    if Setting.where(key: 'epic_test_mode').any?
      Setting.find_by_key('epic_test_mode').update_attribute(:key, 'test_mode')
    end

    if Setting.where(key: 'epic_wsdl').any?
      Setting.find_by_key('epic_wsdl').update_attribute(:key, 'wsdl')
    end
  end
end
