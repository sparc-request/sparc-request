# Copyright © 2011-2022 MUSC Foundation for Research Development~
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
    errors = nil

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
      errors = "Pricing map errors - #{pricing_map.errors.messages.map{ |k,v| "#{k}: #{v}"}.join(', ')}"
      puts "#"*50
      puts "Error importing pricing map for Service #{service.id}"
      puts errors
    end

    return errors
  end

  revenue_codes = []
  cpt_codes = []
  is_available = []
  service_names = []
  pricing_maps = []
  skipped_services = []
  puts ""
  puts "Reading in file..."
  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the services. Are you sure you want to continue? (y/n): ')

  if (continue == 'y') || (continue == 'Y')
    ActiveRecord::Base.transaction do
      CSV.foreach(input_file, headers: true, skip_blanks: true, skip_lines: /^(?:,\s*)+$/, :encoding => 'windows-1251:utf-8') do |row|
        puts row['Service ID'].to_i
        service = Service.where(id: row['Service ID'].to_i).first
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

          service_is_available = service.is_available
          row_is_available = (row['Is Available'].to_i == 1 ? true : false)
          unless service_is_available == row_is_available
            is_available << [service.id, service_is_available]
            puts "Altering the service's is_available status with an id of #{service.id} from #{service_is_available} to #{row_is_available}"
            service.is_available = row_is_available
            updated = true
          end

          unless service.name == row['Procedure Name']
            service_names << [service.id, service.name]
            puts "Altering the name of service with an id of #{service.id} from #{service.name} to #{row['Procedure Name']}"
            service.name = row['Procedure Name']
            updated = true
          end

          if (service.current_effective_pricing_map.full_rate != (row['Service Rate'].to_f * 100))
            puts "Altering service #{service.id} cost from a rate of #{service.current_effective_pricing_map.full_rate} to #{row['Service Rate'].to_i * 100}"
            pm_errors = update_service_pricing(service, row)
            if pm_errors
              skipped_services << [service.id, pm_errors]
            else
              pricing_maps << [service.id, service.current_effective_pricing_map.full_rate]
              updated = true
            end
          elsif (service.current_effective_pricing_map.federal_rate != (row['Federal Rate'].to_f * 100))
            puts "Altering service #{service.id} cost from a rate of #{service.current_effective_pricing_map.federal_rate} to #{row['Federal Rate'].to_i * 100}"
            pm_errors = update_service_pricing(service, row)
            if pm_errors
              skipped_services << [service.id, pm_errors]
            else
              pricing_maps << [service.id, service.current_effective_pricing_map.federal_rate]
              updated = true
            end
          end

          if updated
            service.audit_comment = 'updated by script'
          else
            error_note = "No changes to Service #{service.id}"
            puts "No changes to Service #{service.id}"
            skipped_services << [service.id, error_note]
          end

          service.save
        else
          not_found_error = "Service #{row['Service ID']} not found."
          puts not_found_error
          skipped_services << [row['Service ID'], not_found_error]
        end
      end
    end

    CSV.open("tmp/altered_service_report.csv", "w+") do |csv|
      csv << ['Service Name', 'Service Id', 'EAP ID', 'Column Changed', 'New Attribute', 'Old Attribute', 'Error']
      unless revenue_codes.empty?
        revenue_codes.each do |id_and_code|
          service = Service.find(id_and_code[0])
          csv << [service.name, id_and_code[0], service.eap_id, 'Revenue Code', service.revenue_code, id_and_code[1], nil]
        end
      end

      unless cpt_codes.empty?
        cpt_codes.each do |id_and_code|
          service = Service.find(id_and_code[0])
          csv << [service.name, id_and_code[0], service.eap_id, 'Cpt Code', service.cpt_code, id_and_code[1], nil]
        end
      end

      unless is_available.empty?
        is_available.each do |id_and_code|
          service = Service.find(id_and_code[0])
          csv << [service.name, id_and_code[0], service.eap_id, 'Is Available', service.is_available, id_and_code[1], nil]
        end
      end

      unless service_names.empty?
        service_names.each do |id_and_name|
          service = Service.find(id_and_name[0])
          csv << [service.name, id_and_name[0], service.eap_id, 'Procedure Name', service.name, id_and_name[1], nil]
        end
      end

      unless pricing_maps.empty?
        pricing_maps.each do |id_and_rate|
          service = Service.find(id_and_rate[0])
          csv << [service.name, id_and_rate[0], service.eap_id, 'Pricing Map', service.current_effective_pricing_map.full_rate, id_and_rate[1], nil]
        end
      end

      unless skipped_services.empty?
        skipped_services.each do |id_and_error|
          begin
            service = Service.find(id_and_error[0])
            csv << [service.name, id_and_error[0], service.eap_id, nil, nil, nil, id_and_error[1]]
          rescue ActiveRecord::RecordNotFound
            csv << [nil, id_and_error[0], nil, nil, nil, nil, id_and_error[1]]
          end
        end
      end
    end
  else
    puts 'Exiting rake task...'
  end
end
