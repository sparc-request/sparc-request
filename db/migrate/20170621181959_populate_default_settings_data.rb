class PopulateDefaultSettingsData < ActiveRecord::Migration[5.0]
  include DataTypeValidator

  def change
    array = JSON.parse(File.read('config/defaults.json'))
    ActiveRecord::Base.transaction do
      array.each do |hash|
        if is_boolean?(hash['value'])
          type = 'boolean'
        elsif is_json?(hash['value'])
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
end
