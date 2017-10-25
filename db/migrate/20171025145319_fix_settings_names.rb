class FixSettingsNames < ActiveRecord::Migration[5.1]
  def change
    #Update key names for settings, to match former application.yml names (for initial import), and modify parent key names to match.
    if setting = Setting.find_by_key("use_research_master")
      setting.key = "research_master_enabled"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("research_master_api_url")
      setting.key = "research_master_api"
      setting.parent_key = "research_master_enabled"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("research_master_api_token")
      setting.key = "rmid_api_token"
      setting.parent_key = "research_master_enabled"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("use_system_satisfaction_survey")
      setting.key = "system_satisfaction_survey"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("redcap_api_token")
      setting.key = "redcap_token"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("epic_rights_mail_to")
      setting.key = "approve_epic_rights_mail_to"
      setting.save(validate: false)
    end

    #Update parent id's for settings not themselves having key name changed.
    if (setting = Setting.find_by_key("research_master_link")).parent_key == "use_research_master"
      setting.parent_key = "research_master_enabled"
      setting.save(validate: false)
    end
    if (setting = Setting.find_by_key("system_satisfaction_survey_cc")).parent_key == "use_system_satisfaction_survey"
      setting.parent_key = "system_satisfaction_survey"
      setting.save(validate: false)
    end
  end
end
