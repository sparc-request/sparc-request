desc "Temporary task to populate the settings table"
task :populate_settings_table => :environment do

  file = open('tmp/defaults.json')
  json = file.read

  parsed = JSON.parse(json)
  ActiveRecord::Base.transaction do
    parsed.each do |key, value|
      Setting.create(key: key['name'], value: key['value'], description: key['description'])
    end
  end
end