#####  Import services using a DHHS fee schedule and pricing file
namespace :data do
  desc "Import professional services using the CPT code mapping"
  task :import_professional_services => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    ranges = {}
    CSV.foreach(ENV['range'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      ### POS used so that we can have same org with different ranges
      org_plus_pos = row['ORG ID'] + "-" + row['POS']
      ranges[org_plus_pos] = Range.new(*row['CPT Code Grouping'].split('-').map(&:to_i))
    end

    continue = prompt("Are you sure you want to import services for CPT code ranges #{ranges.inspect} (yes/no)? ")

    raise "Aborted!" unless continue == 'yes'

    Service.transaction do
      begin
        CSV.foreach(ENV['file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
          cpt_code = row['CPT Code'].chomp("26")

          range = ranges.select{|k,v| v.member? cpt_code.to_i}

          if range.empty?
            puts "No CPT code range exists, skipping #{cpt_code} - #{row['Procedure Name']}"
          elsif range.size > 1
            raise "Overlapping ranges: :\n\n#{row.inspect}\n\n#{ranges.inspect}"
          else
            organization_id = range.keys.first.split('-').first # looks like 123-1

            service = Service.new(
                                :organization_id => organization_id,
                                :cpt_code => cpt_code,
                                :send_to_epic => (row['Send to Epic'] == 'Y' ? true : false),
                                :name => 'PB ' + row['Procedure Name'],
                                :abbreviation => 'PB ' + row['Procedure Name'],
                                :order => nil,
                                :one_time_fee => (row['Is One Time Fee?'] == 'Y' ? true : false),
                                :is_available => true)

            service.tag_list = "epic" if row['Send to Epic'] == 'Y'

            full_rate = Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
            corporate_rate = Service.dollars_to_cents(row['Corporate Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
            federal_rate = Service.dollars_to_cents(row['Federal Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
            member_rate = Service.dollars_to_cents(row['Member Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
            other_rate = Service.dollars_to_cents(row['Other Rate'].to_s.strip.gsub("$", "").gsub(",", ""))

            effective_date = row['Effective Date'].match("[0-1]?[0-9]/[0-3]?[0-9]/[0-9]{4}") ? Date.strptime(row['Effective Date'], "%m/%d/%Y") : Date.strptime(row['Effective Date'], "%m/%d/%y") # four digit or two digit year makes a difference
            display_date = row['Display Date'].match("[0-1]?[0-9]/[0-3]?[0-9]/[0-9]{4}") ? Date.strptime(row['Display Date'], "%m/%d/%Y") : Date.strptime(row['Display Date'], "%m/%d/%y") # see above

            pricing_map = service.pricing_maps.build(
                                                  :full_rate => full_rate,
                                                  :corporate_rate => corporate_rate,
                                                  :federal_rate => federal_rate,
                                                  :member_rate => member_rate, 
                                                  :other_rate => other_rate, 
                                                  :unit_type => (row['Is One Time Fee?'] == 'Y' ? nil : row['Clinical Qty Type']),
                                                  :quantity_type => (row['Is One Time Fee?'] != 'Y' ? nil : row['Clinical Qty Type']),
                                                  :unit_factor => row['Unit Factor'],
                                                  :unit_minimum => (row['Is One Time Fee?'] == 'Y' ? nil : row['Qty Min']),
                                                  :quantity_minimum => (row['Is One Time Fee?'] != 'Y' ? nil : row['Qty Min']),
                                                  :display_date => display_date,
                                                  :effective_date => effective_date
                                                  )

            if service.valid? and pricing_map.valid?
              action = service.new_record? ? 'created' : 'updated'
              service.save
              pricing_map.save
              puts "#{service.name} #{action} under #{organization_id}"
            else
              puts "#"*50
              puts "Error importing service"
              puts service.inspect
              puts pricing_map.inspect
              puts service.errors
              puts pricing_map.errors
            end
          end
        end
      rescue Exception => e
        puts "Usage: rake data:import_professional_services file=tmp/file.csv range=tmp/file.csv"
        puts e.message
      end
    end
  end
end
