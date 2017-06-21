class PopulateDefaultSettingsData < ActiveRecord::Migration[5.0]
  def change
  file = open('config/defaults.json')
  json = file.read

  parsed = JSON.parse(json)
  ActiveRecord::Base.transaction do
    parsed.each do |key, value|
      type = ""
      if (key['value'] == 'true') || (key['value'] == 'true')
        type = 'boolean'
      elsif key['value'][0] == '['
        type = 'array'
      elsif key['value'][0] == '{'
        type = 'hash'
      else
        type = 'string'
      end

      Setting.create(key: key['name'], value: key['value'], description: key['description'], data_type: type)
    end
  end
end
