#####  Import services using a DHHS fee schedule and pricing file
namespace :data do
  desc "Import hospital based services using the DHHS rates"
  task :import_hospital_services => :environment do
    Service.transaction do
      begin
        current_version = RevenueCodeRange.maximum('version').to_i

        CSV.foreach(ENV['hospital_file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
          
          associated_revenue_code_range = RevenueCodeRange.find_by_sql("SELECT * FROM revenue_code_ranges WHERE version = #{current_version} AND #{row['Revenue Code'].to_i} BETWEEN `from` AND `to`")
          if associated_revenue_code_range.empty?
            # what do we do
            puts "No revenue code range found, skipping #{row['Charge Code']} - #{row['Procedure Name']} - #{row['Revenue Code']}"
          elsif associated_revenue_code_range.size > 1
            raise "Why do we have multiple revenue code ranges for:\n\n#{row.inspect}\n\n#{associated_revenue_code_range.inspect}"
          else
            range = associated_revenue_code_range.first
            organization = range.organization

            #CPT Code,Charge Code,Revenue Code,Send to Epic,Procedure Name,Service Rate, Corporate Rate ,Federal Rate,Member Rate,Other Rate,Is One Time Fee?,Clinical Qty Type,Unit Factor,Qty Min,Display Date,Effective Date
            #111111,11000001,0113,Y,ROOM & BOARD - PRIVATE GENERAL," 1,328.00 "," 1,177.27 "," 1,177.27 "," 1,177.27 "," 1,177.27 ",N,Each,1,1,11/21/14,11/21/14

            attr = {:charge_code => row['Charge Code'], :organization_id => organization.id, :revenue_code_range_id => range.id}
            service = Service.where(attr).first || Service.new(attr)
            service.assign_attributes(
                                :revenue_code => row['Revenue Code'],
                                :cpt_code => row['CPT Code'],
                                :send_to_epic => (row['Send to Epic'] == 'Y' ? true : false),
                                :name => row['Procedure Name'],
                                :abbreviation => row['Procedure Name'],
                                :order => nil,
                                :is_available => true)

            service.tag_list = "epic" if row['Send to Epic'] == 'Y'

            full_rate = Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
            calculated_rate = (full_rate * range.percentage)/100.0

            pricing_map = service.pricing_maps.build(
                                                  :full_rate => Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                                  :corporate_rate => calculated_rate,
                                                  :federal_rate => calculated_rate,
                                                  :member_rate => calculated_rate, 
                                                  :other_rate => calculated_rate, 
                                                  :is_one_time_fee => (row['Is One Time Fee?'] == 'Y' ? true : false),
                                                  :unit_type => (row['Is One Time Fee?'] == 'Y' ? nil : row['Clinical Qty Type']),
                                                  :quantity_type => (row['Is One Time Fee?'] != 'Y' ? nil : row['Clinical Qty Type']),
                                                  :unit_factor => row['Unit Factor'],
                                                  :unit_minimum => (row['Is One Time Fee?'] == 'Y' ? nil : row['Qty Min']),
                                                  :quantity_minimum => (row['Is One Time Fee?'] != 'Y' ? nil : row['Qty Min']),
                                                  :display_date => Date.strptime(row['Display Date'], "%m/%d/%y"),
                                                  :effective_date => Date.strptime(row['Effective Date'], "%m/%d/%y")
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
        puts "Usage: rake data:import_hospital_services rate_file=tmp/hospital_file.csv"
        puts e.message
      end
    end
  end
end
