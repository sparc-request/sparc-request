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
  desc "Import protocols from CSV"
  task :import_protocols => :environment do
    def header
      [
        "Human Subjects?",
        "PRO#",
        "HR#",
        "Short Title",
        "Protocol Title",
        "Primary PI",
        "Research Assistant/Coordinator",
        "Role",
        "Department",
        "Funded",
        "Funding Source",
        "Sponsor"
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

            study = Study.new(
                           :short_title => row['Short Title'],
                           :title => row['Protocol Title'],
                           :funding_status => (row['Funded'] == 'Y' ? 'funded' : 'pending_funding'),
                           :funding_source => (row['Funded'] == 'Y' ? FUNDING_SOURCES[row['Funding Source']] : nil),
                           :potential_funding_source => (row['Funded'] != 'Y' ? POTENTIAL_FUNDING_SOURCES[row['Funding Source']] : nil),
                           :sponsor_name => row['Sponsor'])

            research_types_info = study.build_research_types_info(:human_subjects => true)

            human_subjects_info = study.build_human_subjects_info(
                                                              :hr_number => row['HR#'],
                                                              :pro_number => row['PRO#'])
            
            if row['Primary PI'].nil?
              puts "Skipping #{row['Short Title']} because the Primary PI was not specified"
              puts ""
              skipped_rows["nil"] << row
              next
            else
              ppi_query = "#{row['Primary PI'].strip}"                                              
              primary_pi_search = Directory.search(ppi_query)

              if primary_pi_search.empty?
                puts "Skipping #{row['Short Title']} because we couldn't locate the Primary PI"
                puts ""
                skipped_rows["couldn't locate"] << row 
                next 
              elsif primary_pi_search.size > 1 and primary_pi_search.all?{|i| i.ldap_uid == ppi_query}
                puts "Skipping #{row['Short Title']} because we located more than 1 Primary PI with netid='#{ppi_query}'"
                puts ""
                skipped_rows["multiple found"] << row 
                next
              end

              ppi = primary_pi_search.reject{|i| i.ldap_uid != "#{ppi_query}@musc.edu"}.first
              study.requester_id = ppi.id

              primary_pi = study.project_roles.build(
                                                :identity_id => ppi.id, 
                                                :project_rights => 'approve',
                                                :role => 'primary-pi')
            end

            if not row['Research Assistant/Coordinator'].nil? #skip adding coordinator since we don't have a netid
              rac_query = "#{row['Research Assistant/Coordinator'].strip}"
              research_assistant_coordinator_search = Directory.search(rac_query)

              if research_assistant_coordinator_search.empty?
                puts "Skipping #{row['Short Title']} because we couldn't locate the Research Assistant/Coordinator"
                puts ""
                skipped_rows["couldn't locate"] << row 
                next 
              elsif research_assistant_coordinator_search.size > 1 and research_assistant_coordinator_search.all?{|i| i.ldap_uid == rac_query}
                puts "Skipping #{row['Short Title']} because we located more than 1 Research Assistant/Coordinator with netid='#{rac_query}'"
                puts ""
                skipped_rows["multiple found"] << row 
                next
              end
              
              rac = research_assistant_coordinator_search.reject{|i| i.ldap_uid != "#{rac_query}@musc.edu"}.first

              research_assistant_coordinator = study.project_roles.build(
                                                :identity_id => rac.id,
                                                :project_rights => 'request',
                                                :role => 'research-assistant-coordinator')
            end
           
            # define any extra netids that all protocols should get
            if Rails.env == 'development'
              extra_netids = ['jug2', 'anc63']
            else
              extra_netids = ['jug2']
            end
            extras = []

            extra_netids.each do |netid|

              extra_search = Directory.search(netid)

              #TODO should we be adding validation
              if extra_search.empty?
                puts "Skipping #{row['Short Title']} because we couldn't locate the #{netid}"
                puts ""
                skipped_rows["couldn't locate"] << row 
                next 
              elsif extra_search.size > 1 and extra_search.all?{|i| i.ldap_uid == "#{netid}@musc.edu"}
                puts "Skipping #{row['Short Title']} because we located more than 1 #{netid}"
                puts ""
                skipped_rows["multiple found"] << row 
                next
              end

              extra_i = extra_search.reject{|i| i.ldap_uid != "#{netid}@musc.edu"}.first
              extras << study.project_roles.build(
                                                :identity_id => extra_i.id,
                                                :project_rights => 'request',
                                                :role => 'general-access-user')
            end

            if study.valid? and research_types_info.valid? and human_subjects_info.valid? and primary_pi.valid?
              study.save
              human_subjects_info.save
              primary_pi.save
              if not row['Research Assistant/Coordinator'].nil? #skip adding coordinator since we don't have a netid
                research_assistant_coordinator.save
              end
              extras.each do |extra_i|
                extra_i.save
              end
            else
              puts "#"*50
              puts "Error importing study"
              puts row.inspect
              puts study.inspect
              puts research_types_info.inspect
              puts human_subjects_info.inspect
              puts primary_pi.inspect
              if not row['Research Assistant/Coordinator'].nil? #skip adding coordinator since we don't have a netid
                puts research_assistant_coordinator.inspect
              end
              extras.each do |extra_i|
                puts extra_i.inspect
              end
              puts study.errors.messages
              puts research_types_info.errors.messages
              puts human_subjects_info.errors.messages
              puts primary_pi.errors.messages
              if not row['Research Assistant/Coordinator'].nil? #skip adding coordinator since we don't have a netid
                puts research_assistant_coordinator.errors.messages
              end
              extras.each do |extra_i|
                puts extra_i.errors.messages
              end
              puts ""

              error_rows[row] = [study.errors.messages, research_types_info.errors.messages, human_subjects_info.errors.messages, primary_pi.errors.messages]
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
      csv << ['Human Subjects?', 'PRO#', 'HR#', 'Short Title', 'Protocol Title', 'Primary PI', 'Research Assistant/Coordinator', 'Funded', 'Funding Source', 'Sponsor', 'Error Message']
      skipped_rows.each do |message, rows|
        rows.each do |row|
          puts "#"*20
          puts message
          puts row.inspect
          puts "#"*20
          # Human Subjects?,Pro#,HR#,Short Title,Protocol Title,Primary PI,Research Assistant/Coordinator,Funded,Funding Source,Sponsor
          csv << [row['Human Subjects?'], row['PRO#'], row['HR#'], row['Short Title'], row['Protocol Title'], row['Primary PI'], row['Research Assistant/Coordinator'], row['Funded'], row['Funding Source'], row['Sponsor'], message]
        end
      end
    end
    puts ""
    puts "Error rows"
    CSV.open(Rails.root.join("db", "imports", "error_rows.csv"), "w+") do |csv|
      csv << ['Human Subjects?', 'PRO#', 'HR#', 'Short Title', 'Protocol Title', 'Primary PI', 'Research Assistant/Coordinator', 'Funded', 'Funding Source', 'Sponsor', 'Protocol Error Message', 'Research Type Info Error Message', 'Human Subject Info Error Message', 'Primary PI Error Message']
      error_rows.each do |row, messages|
        new_row = [row['Human Subjects?'], row['PRO#'], row['HR#'], row['Short Title'], row['Protocol Title'], row['Primary PI'], row['Research Assistant/Coordinator'], row['Funded'], row['Funding Source'], row['Sponsor']]
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

