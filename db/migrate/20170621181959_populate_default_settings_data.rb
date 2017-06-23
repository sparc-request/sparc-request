class PopulateDefaultSettingsData < ActiveRecord::Migration[5.0]
  def change
    file = open('config/defaults.json')
    json = file.read

    parsed = JSON.parse(json)
    ActiveRecord::Base.transaction do
      parsed.each do |key, value|
        type = ""
        if (key['value'] == 'true') || (key['value'] == 'false')
          type = 'boolean'
        elsif (key['value'][0] == '[') || (key['value'][0] == '{')
          type = 'json'
        else
          type = 'string'
        end

        setting = Setting.new
        setting.assign_attributes(key: key['name'], value: key['value'], description: key['description'], data_type: type)
        setting.save(validate: false)
      end
    end
  end
end
