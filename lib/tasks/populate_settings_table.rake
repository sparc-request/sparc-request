desc "Temporary task to populate the settings table"
task :populate_settings_table => :environment do

  environment = Rails.env
  hash = YAML.load_file('config/application.yml')
  hash[environment].each do |key, value|
    type = ""
      if (value.class == TrueClass) || (value.class == FalseClass)
        type = 'boolean'
      elsif value.class == Array
        type = 'array'
      elsif value.class == Hash
        type = 'hash'
      else
        type = 'string'
      end

    Setting.create(key: key, value: value, data_type: type)
  end
end