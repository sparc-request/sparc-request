namespace :data do
  desc "Import pricing maps from CSV"
  task :import_pricing_maps => :environment do
    def header
      [
       "ID",
       "Procedure Name",
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

    continue = prompt("Are you sure you want to import pricing maps from #{file}? (Yes/No) ")

    if continue == 'Yes'
      puts ""
      puts "#"*50
      puts "Starting import"
      input_file = Rails.root.join("db", "imports", file)
      CSV.foreach(input_file, :headers => true) do |row|
        service = Service.find(row['ID'].to_i)

        pricing_map = service.pricing_maps.build(
                                              :full_rate => Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :corporate_rate => Service.dollars_to_cents(row['Corporate Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :federal_rate => Service.dollars_to_cents(row['Federal Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :member_rate => Service.dollars_to_cents(row['Member Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :other_rate => Service.dollars_to_cents(row['Other Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :is_one_time_fee => (row['Is One Time Fee?'] == 'Y' ? true : false),
                                              :unit_type => (row['Is One Time Fee?'] == 'Y' ? nil : row['Clinical Qty Type']),
                                              :quantity_type => (row['Is One Time Fee?'] != 'Y' ? nil : row['Clinical Qty Type']),
                                              :unit_factor => row['Unit Factor'],
                                              :unit_minimum => (row['Is One Time Fee?'] == 'Y' ? nil : row['Qty Min']),
                                              :quantity_minimum => (row['Is One Time Fee?'] != 'Y' ? nil : row['Qty Min']),
                                              :display_date => Date.strptime(row['Display Date'], "%m/%d/%y"),
                                              :effective_date => Date.strptime(row['Effective Date'], "%m/%d/%y")
                                              )

        if pricing_map.valid?
          #puts service.inspect
          #puts pricing_map.inspect
          puts "Pricing map created for #{service.name}"
          pricing_map.save
        else
          puts "#"*50
          puts "Error importing pricing map"
          puts service.inspect
          puts pricing_map.inspect
          puts service.errors
          puts pricing_map.errors
        end
      end
    else
      puts "Import aborted, please start over"
      exit
    end
  end
end

