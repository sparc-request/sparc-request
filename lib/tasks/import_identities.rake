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

namespace :data do
  desc "Import identities from CSV"
  task :import_identities => :environment do
    def header
      [
        "Protocol ID",
        "User NetID",
        "SPARC Role",
        "SPARC Right",
        "Epic Access Y/N"
      ]
    end

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def get_file(error=false)
      puts "No import file specified or the file specified does not exist in db/imports" if error
      file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "

      while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
        file = get_file(true)
      end

      file
    end

    def verify_header(file)
      input_file = Rails.root.join("db", "imports", file)
      CSV.foreach(input_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
        return row.headers.sort == header.sort
      end
    end

    begin 

      puts "Press CTRL-C to exit"
      puts ""

      file = get_file
      proper_header = verify_header(file)

      continue = prompt("Are you sure you want to continue importing? (Yes/No) ")
      skipped_rows ={"couldn't locate" => [], "multiple found" => [], "nil" => []}
      error_rows = {}

      if continue == 'Yes'
        ActiveRecord::Base.transaction do
          puts ""
          puts "#"*50
          puts "Starting import"

          skipped_rows ={"couldn't locate" => [], "multiple found" => [], "nil" => []}
          error_rows = {}
          input_file = Rails.root.join("db", "imports", file)

          CSV.foreach(input_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
            puts ""
            puts row.inspect

            study = Study.find row['Protocol ID'] rescue nil

            if study.nil?
              puts "Skipping #{row['Protocol ID']} because the study couln't be located"
              puts ""
              skipped_rows["couldn't locate"] << row
              next
            end

            if row['User NetID'].nil?
              puts "Skipping #{study.short_title} because the User NetID was not specified"
              puts ""
              skipped_rows["nil"] << row
              next
            else
              ldap_uid = "#{row['User NetID'].strip}@musc.edu"
              next if study.identities.map(&:ldap_uid).include? ldap_uid
              
              identity_search = Directory.search(ldap_uid)

              if identity_search.empty?
                puts "Skipping #{study.short_title} because we couldn't locate the identity"
                puts ""
                skipped_rows["couldn't locate"] << row 
                next 
              elsif identity_search.size > 1 and identity_search.all?{|i| i.ldap_uid == ldap_uid} 
                puts "Skipping #{study.short_title} because we located more than 1 identity with netid='#{ldap_uid}'"
                puts ""
                skipped_rows["multiple found"] << row 
                next
              end

              identity = identity_search.first 
              if row['Epic Access Y/N'].strip == 'Y'
                identity_role = study.project_roles.build(
                                                  :identity_id => identity.id, 
                                                  :project_rights => row['SPARC Right'],
                                                  :epic_access => true,
                                                  :role => row['SPARC Role'],
                                                  :epic_rights_attributes => 
                                                    [{:right => 'view_rights'},
                                                     {:right => 'enter_data'},
                                                     {:right => 'schedule_research'},
                                                     {:right => 'enter_orders'},
                                                     {:right => 'process_orders'},
                                                     {:right => 'approve'},
                                                     {:right => 'complete'}
                                                    ]
                                                  )
              else
                identity_role = study.project_roles.build(
                                                  :identity_id => identity.id, 
                                                  :project_rights => row['SPARC Right'],
                                                  :epic_access => false,
                                                  :role => row['SPARC Role']
                                                  )
              end
            end

            if identity_role.valid? 
              puts identity_role.inspect
              #identity_role.save
            else
              puts "#"*50
              puts "Error importing identity"
              puts row.inspect
              puts identity_role.inspect
              puts identity_role.errors.messages
              error_rows[row] = [identity_role.errors.messages]
            end
          end
        end
      else
        puts "Import aborted, please start over"
        exit
      end
    
    puts ""
    puts ""
    puts "#"*50
    puts "Skipped rows"
    CSV.open(Rails.root.join("db", "imports", "skipped_rows.csv"), "w+") do |csv|
      csv << ['Protocol ID', 'User NetID', 'SPARC Role', 'SPARC Right', 'Epic Access Y/N', 'Error Message']
      skipped_rows.each do |message, rows|
        rows.each do |row|
          puts "#"*20
          puts message
          puts row.inspect
          puts "#"*20
          csv << [row['Protocol ID'], row['User NetID'], row['SPARC Role'], row['SPARC Right'], row['Epic Access Y/N'], message]
        end
      end
    end
    puts ""
    puts "Error rows"
    CSV.open(Rails.root.join("db", "imports", "error_rows.csv"), "w+") do |csv|
      csv << ['Protocol ID', 'User NetID', 'SPARC Role', 'SPARC Right', 'Epic Access Y/N', 'Error Message', 'Identity Error Message']
      error_rows.each do |row, messages|
        new_row = [row['Protocol ID'], row['User NetID'], row['SPARC Role'], row['SPARC Right'], row['Epic Access Y/N']]
        puts "#"*20
        messages.each do |message|
          puts message
          new_row << message
        end
        puts row.inspect
        csv << new_row
        puts "#"*20
      end
    end
    puts ""

    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end

