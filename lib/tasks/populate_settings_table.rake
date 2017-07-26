desc "Temporary task to populate the settings table"
task :populate_settings_table => :environment do

  include DataTypeValidator

  environment = Rails.env
  hash = JSON.parse(File.read('config/defaults.json'))
  ActiveRecord::Base.transaction do
    hash[environment].each do |key, value|
      if [TrueClass, FalseClass].include?(value.class)
        type = 'boolean'
        value = value.to_s
      elsif [Array, Hash].include?(value.class)
        type = 'json'
      elsif is_email?(value)
        type = 'email'
      elsif is_url?(value)
        type = 'url'
      elsif is_path?(value)
        type = 'path'
      else
        type = 'string'
      end

      setting = Setting.new
      setting.assign_attributes(key: key, value: value, data_type: type, friendly_name: key.titleize, description: key.humanize)
      setting.save(validate: false)
    end
  end
end
