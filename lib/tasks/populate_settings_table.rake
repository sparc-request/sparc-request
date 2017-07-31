desc "Temporary task to populate the settings table"
task :populate_settings_table => :environment do

  # TODO: Move to migration

  include DataTypeValidator

  environment = Rails.env
  array = JSON.parse(File.read('config/defaults.json'))
  ActiveRecord::Base.transaction do
    array.each do |hash|
      if [TrueClass, FalseClass].include?(hash['value'].class)
        type = 'boolean'
        hash['value'] = hash['value'].to_s
      elsif [Array, Hash].include?(hash['value'].class)
        type = 'json'
      elsif is_email?(hash['value'])
        type = 'email'
      elsif is_url?(hash['value'])
        type = 'url'
      elsif is_path?(hash['value'])
        type = 'path'
      else
        type = 'string'
      end

      setting = Setting.create(
        key:            hash['key'],
        value:          hash['value'],
        data_type:      type,
        friendly_name:  hash['friendly_name'],
        description:    hash['description'],
        group:          hash['group'],
        version:        hash['version'],
      )

      setting.parent_key    = hash['parent_key']
      setting.parent_value  = hash['parent_value']
      setting.save(validate: false)
    end
  end
end
