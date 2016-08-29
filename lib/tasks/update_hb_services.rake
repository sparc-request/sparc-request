# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

desc "Adding eap_id to services and updating columns"
task :add_eap_id => :environment do

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
     'service_id',
     'name',
     'cpt_code',
     'eap_id',
     'revenue_code',
     'is_available',
     'organization_id',
     'line_items_count',
     'description'
    ]
  end

  revenue_codes = []
  cpt_codes = []
  service_names = []
  puts ""
  puts "Reading in file..."
  input_file = Rails.root.join("db", "imports", get_file)
  continue = prompt('Preparing to modify the services. Are you sure you want to continue? (y/n): ')

  if continue == 'y'
    ActiveRecord::Base.transaction do
      CSV.foreach(input_file, :headers => true) do |row|
        service = Service.find(row['service_id'].to_i)
        puts ""
        puts ""
        puts "Adding eap id to service #{service.name}"

        service.eap_id = row['eap_id']
        
        unless service.revenue_code == row['revenue_code'].rjust(4, '0')
          revenue_codes << [service.id, service.revenue_code]
          service.revenue_code = row['revenue_code'].rjust(4, '0')  
        end

        unless service.cpt_code == row['cpt_code']
          cpt_codes << [service.id, service.cpt_code]
          service.cpt_code = row['cpt_code'] == 'NULL' ? nil : row['cpt_code']     
        end

        unless service.name == row['name']
          service_names << [service.id, service.name]
          service.name = row['name'] 
        end

        service.save
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
          csv << [service.name, id_and_name[0], 'Service Name', id_and_name[1]]
        end
      end
    end
  end
end
