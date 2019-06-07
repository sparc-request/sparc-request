# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

desc "Updating service columns as needed"
task :update_hb_services => :environment do

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

  def header
    [
     'Service ID',
     'EAP ID',
     'CPT Code',
     'Revenue Code',
     'Procedure Name',
     'Service Rate',
     'Corporate Rate',
     'Federal Rate',
     'Member Rate',
     'Other Rate',
     'Is One Time Fee?',
     'Clinical Qty Type',
     'Unit Factor',
     'Qty Min',
     'Display Date',
     'Effective Date'
    ]
  end

  def update_service_pricing(service, row)
    pricing_map = service.pricing_maps.build( full_rate: Service.dollars_to_cents(row['Service Rate'].to_s),
                                              corporate_rate: Service.dollars_to_cents(row['Corporate Rate'].to_s),
                                              federal_rate: Service.dollars_to_cents(row['Federal Rate'].to_s),
                                              member_rate: Service.dollars_to_cents(row['Member Rate'].to_s),
                                              other_rate: Service.dollars_to_cents(row['Other Rate'].to_s),
                                              unit_factor: row['Unit Factor'],
                                              unit_type: row['Clinical Qty Type'],
                                              unit_minimum: row['Qty Min'],
                                              units_per_qty_max: service.current_effective_pricing_map.units_per_qty_max,
                                              quantity_type: service.current_effective_pricing_map.quantity_type,
                                              otf_unit_type: service.current_effective_pricing_map.otf_unit_type,
                                              quantity_minimum: service.current_effective_pricing_map.quantity_minimum,
                                              display_date: Date.strptime(row['Display Date'], "%m/%d/%y"),
                                              effective_date: Date.strptime(row['Effective Date'], "%m/%d/%y"),
                                              audit_comment: 'created by script'
                                              )
    if pricing_map.valid?
      pricing_map.save
    else
      puts "#"*50
      puts "Error importing pricing map"
      puts service.inspect
      puts pricing_map.inspect
      puts service.errors.inspect
      puts pricing_map.errors.inspect
    end
  end

  revenue_codes = []
  cpt_codes = []
  service_names = []
  pricing_maps = []
  puts ""
  puts "Reading in file..."
  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the services. Are you sure you want to continue? (y/n): ')

  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      CSV.foreach(input_file, :headers => true) do |row|
        service = Service.where(id: row['Service ID'].to_i).first
        puts ""
        puts ""
        updated = false
        
        if service
          unless service.revenue_code == row['Revenue Code'].rjust(4, '0')
            revenue_codes << [service.id, service.revenue_code]
            puts "Altering the revenue code of service with an id of #{service.id} from #{service.revenue_code} to #{row['Revenue Code']}"
            service.revenue_code = row['Revenue Code'].rjust(4, '0') 
            updated = true 
          end

          unless service.cpt_code == row['CPT Code']
            cpt_codes << [service.id, service.cpt_code]
            puts "Altering the CPT code of service with an id of #{service.id} from #{service.cpt_code} to #{row['CPT Code']}"
            service.cpt_code = row['CPT Code'] == 'NULL' ? nil : row['CPT Code'] 
            updated = true    
          end

          unless service.name == row['Procedure Name']
            service_names << [service.id, service.name]
            puts "Altering the name of service with an id of #{service.id} from #{service.name} to #{row['Procedure Name']}"
            service.name = row['Procedure Name'] 
            updated = true
          end

          unless service.current_effective_pricing_map.full_rate == (row['Service Rate'].to_i * 100)
            pricing_maps << [service.id, service.current_effective_pricing_map.full_rate]
            puts "Altering service #{service.id} cost from a rate of #{service.current_effective_pricing_map.full_rate} to #{row['Service Rate'].to_i * 100}"
            update_service_pricing(service, row)
            updated = true
          end

          if updated
            service.audit_comment = 'updated by script'
          end

          service.save
        end
      end
    end

    CSV.open("tmp/altered_service_report.csv", "w+") do |csv|
      csv << ['Service Name', 'Service Id', 'Column Changed', 'New Attribute', 'Old Attribute']
      unless revenue_codes.empty?
        revenue_codes.each do |id_and_code|
          service = Service.find(id_and_code[0])
          csv << [service.name, id_and_code[0], 'Revenue Code', service.revenue_code, id_and_code[1]]
        end
      end

      unless cpt_codes.empty?
        cpt_codes.each do |id_and_code|
          service = Service.find(id_and_code[0])
          csv << [service.name, id_and_code[0], 'Cpt Code', service.cpt_code, id_and_code[1]]
        end
      end

      unless service_names.empty?
        service_names.each do |id_and_name|
          service = Service.find(id_and_name[0])
          csv << [service.name, id_and_name[0], 'Procedure Name', service.name, id_and_name[1]]
        end
      end

      unless pricing_maps.empty?
        pricing_maps.each do |id_and_rate|
          service = Service.find(id_and_rate[0])
          csv << [service.name, id_and_rate[0], 'Pricing Map', service.current_effective_pricing_map.full_rate, id_and_rate[1]]
        end
      end
    end
  else
    puts 'Exiting rake task...'
  end
end
