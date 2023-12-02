desc "Add or update a setting to use additional funding sources"
task add_setting_for_additional_funding_sources: :environment do
  setting = Setting.find_by(key: "use_additional_funding_sources")
  if setting
    setting.update(value: "true", data_type: "boolean")
    puts "Setting already exists. Value set to true."
  else
    Setting.create(key: "use_additional_funding_sources", value: "true", data_type: "boolean")
    puts 'Setting created. Value set to true.'
  end
end
