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
  desc "Import services from CSV"
  task :import_services => :environment do
    def header
      [
       "CPT Code",
       "Send to Epic",
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

    def has_valid_rates?(pricing_map)
      rate_array = [pricing_map.corporate_rate, pricing_map.federal_rate, 
                    pricing_map.member_rate, pricing_map.other_rate]
      rate_array.each do |rate|
        if (rate > pricing_map.full_rate)
          return false
        end
      end
    end

    def generate_bad_rate_report(rate_array)
      CSV.open("tmp/bad_rate_report.csv", "w+") do |csv|
        csv << ["CPT Code", "Procedure Name", "Service Rate", "Corporate Rate", "Federal Rate", "Member Rate", "Other Rate"]
        rate_array.each do |rates|
          service = rates[0]
          pricing_map = rates[1]
          csv << [service.cpt_code, service.name, pricing_map.full_rate, pricing_map.corporate_rate, pricing_map.federal_rate,
                  pricing_map.member_rate, pricing_map.other_rate]
        end
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
    pricing_maps_with_bad_rates = []
    continue = prompt("Are you sure you want to import #{file} into #{org_labels.join(" -> ")}? (Yes/No) ")

    if continue == 'Yes'
      puts ""
      puts "#"*50
      puts "Starting import"
      input_file = Rails.root.join("db", "imports", file)
      services_imported = 0
      CSV.foreach(input_file, :headers => true) do |row|
        service = Service.new(
                            :cpt_code => row['CPT Code'],
                            :send_to_epic => (row['Send to Epic'] == 'Y' ? true : false),
                            :name => ('PB ' + row['Procedure Name']),
                            :abbreviation => row['Abbreviation'],
                            :order => 1,
                            :organization_id => org.id,
                            :one_time_fee => (row['Is One Time Fee?'] == 'Y' ? true : false),
                            :is_available => true)

        service.tag_list = "epic" if row['Send to Epic'] == 'Y'

        pricing_map = service.pricing_maps.build(
                                              :full_rate => Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :corporate_rate => Service.dollars_to_cents(row['Corporate Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :federal_rate => Service.dollars_to_cents(row['Federal Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :member_rate => Service.dollars_to_cents(row['Member Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :other_rate => Service.dollars_to_cents(row['Other Rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :unit_type => (row['Is One Time Fee?'] == 'Y' ? nil : row['Clinical Qty Type']),
                                              :quantity_type => (row['Is One Time Fee?'] != 'Y' ? nil : row['Clinical Qty Type']),
                                              :unit_factor => row['Unit Factor'],
                                              :unit_minimum => (row['Is One Time Fee?'] == 'Y' ? nil : row['Qty Min']),
                                              :quantity_minimum => (row['Is One Time Fee?'] != 'Y' ? nil : row['Qty Min']),
                                              :display_date => Date.strptime(row['Display Date'], "%m/%d/%y"),
                                              :effective_date => Date.strptime(row['Effective Date'], "%m/%d/%y")
                                              )

        if service.valid? and pricing_map.valid?
          unless has_valid_rates?(pricing_map)
            pricing_maps_with_bad_rates << [service, pricing_map]
          else
            service.save
            pricing_map.save
            services_imported += 1
            puts "Saving #{service.name} with an id of #{service.id}"
            puts "#{services_imported} services imported."
          end
        else
          puts "#"*50
          puts "Error importing service"
          puts service.inspect
          puts pricing_map.inspect
          puts service.errors
          puts pricing_map.errors
        end
      end #End of csv import

      puts "#"*50
      if pricing_maps_with_bad_rates.size > 0
        puts 'There were pricing maps with bad rates, a report has been generated in the tmp folder.'
        generate_bad_rate_report(pricing_maps_with_bad_rates)
      else
        puts "All pricing maps have correct rates."
      end

    else
      puts "Import aborted, please start over"
      exit
    end
  end
end

