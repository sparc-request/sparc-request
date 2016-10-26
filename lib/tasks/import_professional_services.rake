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

#####  Import services using a DHHS fee schedule and pricing file
namespace :data do
  desc "Import professional services using the CPT code mapping"
  task :import_professional_services => :environment do
    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    skipped_services = CSV.open("tmp/skipped_pb_services_#{Time.now.strftime('%m%d%Y%T')}.csv", "wb")

    skipped_services << ['REASON','EAP ID','CPT Code','Charge Code','Revenue Code','Send to Epic','Procedure Name','Service Rate','Corporate Rate','Federal Rate','Member Rate','Other Rate','Is One Time Fee?','Clinical Qty Type','Unit Factor','Qty Min','Display Date','Effective Date']

    # Hash value defaults to an empty array
    ranges = Hash.new { |h, k| h[k] = [] }
    CSV.foreach(ENV['range_file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      ranges[row.fetch('ORG ID')] << Range.new(row.fetch('From'), row.fetch('To'))
    end

    Service.transaction do
      CSV.foreach(ENV['pb_file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
        begin
          eap_id = row.fetch('EAP ID')

          # ranges that contain our eap_id
          range = ranges.select do |org_id, org_ranges|
            org_ranges.any? { |org_range| org_range.include?(eap_id) }
          end

          if range.empty?
            puts "No EAP ID range exists, skipping #{eap_id} - #{row.fetch('Procedure Name')}"
            skipped_services << ['No EAP ID range found'] + row.fields
          elsif range.size > 1
            raise "Overlapping ranges: :\n\n#{row.inspect}\n\n#{ranges.inspect}"
            skipped_services << ['Multiple EAP ID ranges found'] + row.fields
          else
            organization_id = range.keys.first.to_i

            attrs = {:eap_id => row.fetch('EAP ID'), :organization_id => organization_id}

            service = Service.where(attrs).first || Service.new(attrs)

            service.assign_attributes(
                                :organization_id => organization_id,
                                :cpt_code => row.fetch('CPT Code'),
                                :send_to_epic => (row.fetch('Send to Epic') == 'Y' ? true : false),
                                :name => row.fetch('Procedure Name'),
                                :abbreviation => row.fetch('Procedure Name'),
                                :order => 1,
                                :one_time_fee => (row.fetch('Is One Time Fee?') == 'Y' ? true : false),
                                :is_available => true)

            service.tag_list = "epic" if row.fetch('Send to Epic') == 'Y'

            full_rate = Service.dollars_to_cents(row.fetch('Service Rate').to_s.strip.gsub("$", "").gsub(",", ""))
            corporate_rate = Service.dollars_to_cents(row.fetch('Corporate Rate').to_s.strip.gsub("$", "").gsub(",", ""))
            federal_rate = Service.dollars_to_cents(row.fetch('Federal Rate').to_s.strip.gsub("$", "").gsub(",", ""))
            member_rate = Service.dollars_to_cents(row.fetch('Member Rate').to_s.strip.gsub("$", "").gsub(",", ""))
            other_rate = Service.dollars_to_cents(row.fetch('Other Rate').to_s.strip.gsub("$", "").gsub(",", ""))

            effective_date = row.fetch('Effective Date').match("[0-1]?[0-9]/[0-3]?[0-9]/[0-9]{4}") ? Date.strptime(row.fetch('Effective Date'), "%m/%d/%Y") : Date.strptime(row.fetch('Effective Date'), "%m/%d/%y") # four digit or two digit year makes a difference
            display_date = row.fetch('Display Date').match("[0-1]?[0-9]/[0-3]?[0-9]/[0-9]{4}") ? Date.strptime(row.fetch('Display Date'), "%m/%d/%Y") : Date.strptime(row.fetch('Display Date'), "%m/%d/%y") # see above

            pricing_map = service.pricing_maps.build(
                                                  :full_rate => full_rate,
                                                  :corporate_rate => corporate_rate,
                                                  :federal_rate => federal_rate,
                                                  :member_rate => member_rate,
                                                  :other_rate => other_rate,
                                                  :unit_type => (row['Is One Time Fee?'] == 'Y' ? nil : row.fetch('Clinical Qty Type')),
                                                  :quantity_type => (row['Is One Time Fee?'] != 'Y' ? nil : row.fetch('Clinical Qty Type')),
                                                  :unit_factor => row.fetch('Unit Factor'),
                                                  :unit_minimum => (row['Is One Time Fee?'] == 'Y' ? nil : row.fetch('Qty Min')),
                                                  :quantity_minimum => (row['Is One Time Fee?'] != 'Y' ? nil : row.fetch('Qty Min')),
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

              all_errors = service.errors.messages.merge(pricing_map.errors.messages)

              skipped_services << [all_errors.to_s] + row.fields
            end
          end
        rescue Exception => e
          puts "Usage: rake data:import_professional_services pb_file=tmp/file.csv range_file=tmp/file.csv"
          puts e.message
          puts e.backtrace.inspect
          puts row.inspect
          skipped_services << [e.message] + row.fields
          next
        end
      end

      skipped_services.close # close out the csv file
    end
  end
end
