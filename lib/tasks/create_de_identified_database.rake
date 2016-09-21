# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

