namespace :data do
  desc "Import protocols from CSV"
  task :import_protocols => :environment do
    def header
      [
        "Human Subjects?",
        "Pro#",
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
      CSV.foreach(input_file, :headers => true) do |row|
        return row.headers.sort == header.sort
      end
    end

    puts "Press CTRL-C to exit"
    puts ""

    file = get_file
    proper_header = verify_header(file)

    continue = prompt("Are you sure you want to continue importing? (Yes/No) ")

    if continue == 'Yes'
      puts ""
      puts "#"*50
      puts "Starting import"
      input_file = Rails.root.join("db", "imports", file)
      CSV.foreach(input_file, :headers => true) do |row|

        study = Study.new(
                       :short_title => row['Short Title'],
                       :title => row['Protocol Title'],
                       :funding_status => (row['Funded'] == 'Y' ? 'funded' : 'pending_funding'),
                       :funding_source => (row['Funded'] == 'Y' ? FUNDING_SOURCES[row['Funding Source']] : nil),
                       :potential_funding_source => (row['Funded'] != 'Y' ? POTENTIAL_FUNDING_SOURCES[row['Funding Source']] : nil),
                       :sponsor_name => row['Sponsor'])

        research_types_info = study.build_research_types_info(:human_subjects => true)

        human_subjects_info = study.build_human_subjects_info(
                                                          :hr_number => row['HR #'],
                                                          :pro_number => row['Pro#'])

        primary_pi_search = Identity.search("#{row['Primary PI']}@musc.edu")

        if primary_pi_search.empty?
          puts "Skipping #{row['Short Title']} because we couldn't locate the Primary PI"
          next 
        elsif primary_pi_search.size > 1
          puts "Skipping #{row['Short Title']} because we located more than 1 Primary PI with netid='#{row['Primary PI']}@musc.edu'"
          next
        end

        study.requester_id = primary_pi_search.first.id

        primary_pi = study.project_roles.build(
                                          :identity_id => primary_pi_search.first.id,
                                          :project_rights => 'approve',
                                          :role => 'primary-pi')

        research_assistant_coordinator_search = Identity.search("#{row['Research Assistant/Coordinator']}@musc.edu")

        if research_assistant_coordinator_search.empty?
          puts "Skipping #{row['Short Title']} because we couldn't locate the Research Assistant/Coordinator"
          next 
        elsif research_assistant_coordinator_search.size > 1
          puts "Skipping #{row['Short Title']} because we located more than 1 Research Assistant/Coordinator with netid='#{row['Research Assistant/Coordinator']}@musc.edu'"
          next
        end

        research_assistant_coordinator = study.project_roles.build(
                                          :identity_id => research_assistant_coordinator_search.first.id,
                                          :project_rights => 'request',
                                          :role => 'research-assistant-coordinator')

        if study.valid? and research_types_info.valid? and human_subjects_info.valid? and primary_pi.valid? and research_assistant_coordinator.valid? 
          study.save
          human_subjects_info.save
          primary_pi.save
          research_assistant_coordinator.save
        else
          puts "#"*50
          puts "Error importing study"
          puts study.inspect
          puts research_types_info.inspect
          puts human_subjects_info.inspect
          puts primary_pi.inspect
          puts research_assistant_coordinator.inspect
          puts study.errors.messages
          puts research_types_info.errors.messages
          puts human_subjects_info.errors.messages
          puts primary_pi.errors.messages
          puts research_assistant_coordinator.errors.messages
        end
      end
    else
      puts "Import aborted, please start over"
      exit
    end
  end
end

