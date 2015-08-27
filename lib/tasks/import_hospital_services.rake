#####  Import services using a DHHS fee schedule and pricing file
namespace :data do
  desc "Import hospital based services using the DHHS rates"
  task :import_hospital_services => :environment do
    Service.transaction do
      begin
        current_version = RevenueCodeRange.maximum('version').to_i
        previous_version = [1, current_version - 1].max

        CSV.foreach(ENV['hospital_file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
          revenue_code = row['Revenue Code'].rjust(4, '0')
          
          previous_associated_revenue_code_range = RevenueCodeRange.find_by_sql("SELECT * FROM revenue_code_ranges WHERE version = #{previous_version} AND #{revenue_code.to_i} BETWEEN `from` AND `to`")
          current_associated_revenue_code_range = RevenueCodeRange.find_by_sql("SELECT * FROM revenue_code_ranges WHERE version = #{current_version} AND #{revenue_code.to_i} BETWEEN `from` AND `to`")

          if current_associated_revenue_code_range.empty?
            # what do we do
            puts "No revenue code range found, skipping #{row['Charge Code']} - #{row['Procedure Name']} - #{revenue_code}"
          elsif current_associated_revenue_code_range.size > 1
            raise "Why do we have multiple revenue code ranges for:\n\n#{row.inspect}\n\n#{current_associated_revenue_code_range.inspect}"
          else
            range = current_associated_revenue_code_range.first
            organization = range.organization

            #CPT Code,Charge Code,Revenue Code,Send to Epic,Procedure Name,Service Rate, Corporate Rate ,Federal Rate,Member Rate,Other Rate,Is One Time Fee?,Clinical Qty Type,Unit Factor,Qty Min,Display Date,Effective Date
            #111111,11000001,0113,Y,ROOM & BOARD - PRIVATE GENERAL," 1,328.00 "," 1,177.27 "," 1,177.27 "," 1,177.27 "," 1,177.27 ",N,Each,1,1,11/21/14,11/21/14
           
            current_range = current_associated_revenue_code_range.first
            previous_range = previous_associated_revenue_code_range.first || current_associated_revenue_code_range.first # if the range did not exist in the previous version

 
            attr_previous = {:charge_code => row['Charge Code'], :organization_id => organization.id, :revenue_code_range_id => previous_range.id} # we want to find based on past revenue_code_range_id for updates first
            attr_current = {:charge_code => row['Charge Code'], :organization_id => organization.id, :revenue_code_range_id => current_range.id} # we want to find based on current revenue_code_range_id for updates second

            service = Service.where(attr_previous).first || Service.where(attr_current).first || Service.new(attr_current) # look for previous range, current range, create new
            service.assign_attributes(
                                :revenue_code_range_id => current_range.id,
                                :revenue_code => revenue_code,
                                :cpt_code => row['CPT Code'],
                                :send_to_epic => (row['Send to Epic'] == 'Y' ? true : false),
                                :name => row['Procedure Name'],
                                :abbreviation => row['Procedure Name'],
                                :order => nil,
                                :one_time_fee => (row['Is One Time Fee?'] == 'Y' ? true : false),
                                :is_available => true)

            service.tag_list = "epic" if row['Send to Epic'] == 'Y'

            full_rate = Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", ""))

            if ENV['addendum_b'] == 'yes'
              corporate_rate = Service.dollars_to_cents(row['Corporate Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
              federal_rate = Service.dollars_to_cents(row['Federal Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
              member_rate = Service.dollars_to_cents(row['Member Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
              other_rate = Service.dollars_to_cents(row['Other Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
            else
              calculated_rate = (full_rate * range.percentage)/100.0
              corporate_rate = calculated_rate
              federal_rate = calculated_rate
              member_rate = calculated_rate
              other_rate = calculated_rate
            end

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
              puts "#{service.name} #{action} under #{organization.name}"
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
        puts "Usage: rake data:import_hospital_services hospital_file=tmp/hospital_file.csv"
        puts e.message
      end
    end
  end
end
