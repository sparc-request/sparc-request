json.(@settings) do |setting|
  json.key            setting_key_link(setting)
  json.data_type      setting.data_type
  json.value          display_setting_value(setting)
  json.friendly_name  setting.friendly_name
  json.description    setting.description
  json.group          setting.group
  json.version        setting.version
  json.parent_key     setting.parent_key
  json.parent_value   setting.parent_value
  json.actions        setting_actions(setting)
end
