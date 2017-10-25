class FixSettingsNames < ActiveRecord::Migration[5.1]
  def change
    #Update key names for settings, to match former application.yml names (for initial import), and modify parent key names to match.
    Setting.find_by_key("use_research_master").update(key: "research_master_enabled") if Setting.find_by_key("use_research_master")
    Setting.find_by_key("research_master_api_url").update(key: "research_master_api", parent_key: "research_master_enabled") if Setting.find_by_key("research_master_api_url")
    Setting.find_by_key("research_master_api_token").update(key: "rmid_api_token", parent_key: "research_master_enabled") if Setting.find_by_key("research_master_api_token")
    Setting.find_by_key("use_system_satisfaction_survey").update(key: "system_satisfaction_survey") if Setting.find_by_key("use_system_satisfaction_survey")
    Setting.find_by_key("redcap_api_token").update(key: "redcap_token") if Setting.find_by_key("redcap_api_token")
    Setting.find_by_key("epic_rights_mail_to").update(key: "approve_epic_rights_mail_to") if Setting.find_by_key("epic_rights_mail_to")

    #Update parent id's for settings not themselves having key name changed.
    Setting.find_by_key("research_master_link").update(parent_key: "research_master_enabled") if Setting.find_by_key("research_master_link").parent_key == "use_research_master"
    Setting.find_by_key("system_satisfaction_survey_cc").update(parent_key: "system_satisfaction_survey") if Setting.find_by_key("system_satisfaction_survey_cc").parent_key == "use_system_satisfaction_survey"
  end
end
