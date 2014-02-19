require 'rake'
namespace :data do
  desc "Copy data from one database to another with option to de-identify the data"
  task :copy => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    config = Rails.configuration.database_configuration

    from = ENV['from']
    to = ENV['to']
    deidentify = ENV['deidentify']
    understand = ENV['auto_accept']

    puts ""
    puts "#### Beginning transfer of data ####"
    puts "Source and destination must be defined in database.yml"
    puts ""

    unless from 
      from = prompt "Please specify the source connection (eg. development)? "
    end
    puts "Source database set to: #{from}"
    puts ""
    
    unless to
      to = prompt "Please specify the destination connection (eg. copy_of_development)? " 
    end
    puts "Destination database set to: #{to}"
    puts ""

    unless deidentify
      deidentify = prompt "Should we de-identify this data after transfer? (y/n) " 
    end
    puts "De-identify data: #{deidentify}"
    puts ""

    unless understand
      understand = prompt "Are you sure you want to do this? #{to} will be dropped and recreated before the copy happens. (y/n) "
      puts ""
    end

    if understand == 'y'
      #get information from config
      from_config = config[from]
      to_config = config[to]
      
      puts "Dropping #{to} and recreating"
      `rake db:drop RAILS_ENV=#{to}`
      `rake db:create RAILS_ENV=#{to}`
      
      puts ""
      puts "Copying data from #{from} to #{to}"
      `mysqldump -u #{from_config['username']} -p'#{from_config['password']}' -h #{from_config['host']} #{from_config['database']} | mysql -u #{to_config['username']} -p'#{to_config['password']}' -h #{to_config['host']} #{to_config['database']}`
      puts ""

      if deidentify == 'y'
        puts "De-identifying the subjects and notes"
        ActiveRecord::Base.establish_connection(to)
        Subject.update_all :name => 'J Doe', :mrn => '123456789', :external_subject_id => 'ABC12345', :dob => Date.today
        Note.update_all :body => 'Removed for de-identification purposes'
      end
        
    else
      puts "Copy aborted, #{to} left untouched"
    end

    puts ""
    puts ""
  end
end

