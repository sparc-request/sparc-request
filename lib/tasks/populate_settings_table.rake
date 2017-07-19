desc "Temporary task to populate the settings table"
task :populate_settings_table => :environment do

  environment = Rails.env
  hash = YAML.load_file('config/application.yml')
  ActiveRecord::Base.transaction do
    hash[environment].each do |key, value|
      if (value.class == TrueClass) || (value.class == FalseClass)
        type = 'boolean'
        value = value.to_s
      elsif (value.class == Array) || (value.class == Hash)
        type = 'json'
      else
        type = 'string'
      end

      setting = Setting.new
      setting.assign_attributes(key: key, value: value, data_type: type, friendly_name: key.titleize, description: key.humanize)
      setting.save(validate: false)
    end
  end
end