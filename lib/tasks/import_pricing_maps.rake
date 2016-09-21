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
  desc "Import pricing maps from CSV"
  task :import_pricing_maps => :environment do

    ### columns used
    # service_id
    # full_rate (most people think of this as the service rate)
    # corporate_rate
    # federal_rate
    # member_rate
    # other_rate
    # is_one_time_fee
    # unit_type
    # quantity_type
    # unit_factor
    # unit_minimum
    # quantity_minimum
    # units_per_qty_max
    # display_date
    # effective_date

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

    puts "Press CTRL-C to exit"
    puts ""

    file = get_file
    continue = prompt("Are you sure you want to import pricing maps from #{file}? (Yes/No) ")

    if continue == 'Yes'
      puts ""
      puts "#"*50
      puts "Starting import"
      input_file = Rails.root.join("db", "imports", file)
      CSV.foreach(input_file, :headers => true) do |row|
        service = Service.find(row['service_id'].to_i)

        pricing_map = service.pricing_maps.build(
                                              :full_rate => Service.dollars_to_cents(row['full_rate'].to_s.strip.gsub("$", "").gsub(",", "")),
                                              :corporate_rate => (row['corporate_rate'].blank? ? nil : Service.dollars_to_cents(row['corporate_rate'].to_s.strip.gsub("$", "").gsub(",", ""))),
                                              :federal_rate => (row['federal_rate'].blank? ? nil : Service.dollars_to_cents(row['federal_rate'].to_s.strip.gsub("$", "").gsub(",", ""))),
                                              :member_rate => (row['member_rate'].blank? ? nil : Service.dollars_to_cents(row['member_rate'].to_s.strip.gsub("$", "").gsub(",", ""))),
                                              :other_rate => (row['other_rate'].blank? ? nil : Service.dollars_to_cents(row['other_rate'].to_s.strip.gsub("$", "").gsub(",", ""))),
                                              :unit_type => row['unit_type'],
                                              :quantity_type => row['quantity_type'],
                                              :unit_factor => row['unit_factor'],
                                              :unit_minimum => row['unit_minimum'],
                                              :quantity_minimum => row['quantity_minimum'],
                                              :units_per_qty_max => row['units_per_qty_max'],
                                              :display_date => Date.strptime(row['display_date'], "%m/%d/%y"),
                                              :effective_date => Date.strptime(row['effective_date'], "%m/%d/%y")
                                              )

        if pricing_map.valid?
          puts "New pricing map created for #{service.name}"
          puts "  full_rate = $ #{pricing_map.full_rate / 100}"
          puts "  corporate_rate = $ #{pricing_map.corporate_rate / 100}"
          puts "  federal_rate = $ #{pricing_map.federal_rate / 100}"
          puts "  member_rate = $ #{pricing_map.member_rate / 100}"
          puts "  other_rate = $ #{pricing_map.other_rate / 100}"
          puts ""
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

