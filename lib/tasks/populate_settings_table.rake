desc "Temporary task to populate the settings table"
task :populate_settings_table => :environment do

  File.open('/tmp/some_file.json', 'r') do |file|
    default_value_hash = JSON.parse file
    default_value_hash.each do |key, value|
      puts key
      puts value
    end
  end
end