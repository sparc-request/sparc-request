namespace :data do
  desc "Import services from CSV"
  task :import => :environment do
    def header
      [
       "CPT Code",
       "CDM Code",
       "Send to Epic",
       "Procedure Name",
       "Abbreviation",
       "Order",
       "Service Rate",
       "Corporate Rate",
       "Federal Rate",
       "Member Rate",
       "Other Rate",
       "Is One Time Fee?",
       "Clinical Qty Type",
       "Unit Factor",
       "Qty Min",
       "Display Date",
       "Effective Date"
      ]
    end

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def list_orgs
      puts "#"*50
      institutions = Institution.order(:name)
      institutions.each do |inst|
        puts "- #{inst.name} => #{inst.id}"

        inst.providers.order(:name).each do |prov|
          puts "--- #{prov.name} => #{prov.id}"
          
          prov.programs.order(:name).each do |prog|
            puts "----- #{prog.name} => #{prog.id}"

            prog.cores.order(:name).each do |core|
              puts "------- #{core.name} => #{core.id}"
            end
          end
        end

        puts ""
      end
      puts "#"*50
    end

    def get_file(error=false)
      puts "No import file specified or the file specified does not exist in db/imports" if error
      file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "

      while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
        file = get_file(true) 
      end

      file
    end
    
    def get_org_id(error=false)
      puts "ID specified is blank or does not exist" if error
      parent_org_id = prompt "Please specify the ID for the organization which these services should fall under (type List to see available options): "

      while parent_org_id.blank? or Organization.where(:id => parent_org_id.to_i).empty?
        list_orgs if parent_org_id == 'List'
        parent_org_id = get_org_id(parent_org_id != 'List')
      end

      parent_org_id
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
    org_id = get_org_id
    proper_header = verify_header(file)

    org = Organization.find(org_id)
    org_labels = []
    org_labels = org.parents.map(&:label).reverse unless org.parents.empty?
    org_labels << org.label
    continue = prompt("Are you sure you want to import #{file} into #{org_labels.join(" -> ")}? (Yes/No) ")

    if continue == 'Yes'
      puts ""
      puts "#"*50
      puts "Starting import"
      input_file = Rails.root.join("db", "imports", file)
      CSV.foreach(input_file, :headers => true) do |row|
        service = Organization  
      end
    else
      puts "Import aborted, please start over"
      exit
    end
  end
end

