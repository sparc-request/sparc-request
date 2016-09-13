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

namespace :data do
  desc "Reports to run after hospital services are imported"
  task :hospital_service_reports => :environment do
    cpt_grouped_records = Hash.new {|h,k| h[k] = [] }
    all_records = []
    CSV.foreach(ENV['file'], :headers => true, :encoding => 'windows-1251:utf-8') do |row|
      cpt_grouped_records[row['CPT Code']] << row
      all_records << row
    end

    CSV.open("/tmp/duplicate_cpt_codes.csv", "w+") do |csv|
      cpt_grouped_records.each do |cpt_code, rows|
        if rows.size > 1
          rows.each do |row|
            csv << row
          end
        end
      end
    end
    
    CSV.open("/tmp/non_duplicate_cpt_codes.csv", "w+") do |csv|
      cpt_grouped_records.each do |cpt_code, rows|
        if rows.size == 1
          rows.each do |row|
            csv << row
          end
        end
      end
    end

    CSV.open("/tmp/corporate_greater_than_service_rate.csv", "w+") do |csv|
      all_records.each do |row|
        full_rate = Service.dollars_to_cents(row['Service Rate'].to_s.strip.gsub("$", "").gsub(",", ""))
        corporate_rate = Service.dollars_to_cents(row['Corporate Rate'].to_s.strip.gsub("$", "").gsub(",", ""))

        csv << row if corporate_rate > full_rate
      end
    end

    puts "Created /tmp/duplicate_cpt_codes.csv based off #{ENV['file']}"
    puts "Created /tmp/non_duplicate_cpt_codes.csv based off #{ENV['file']}"
    puts "Created /tmp/corporate_greater_than_service_rate.csv based off #{ENV['file']}"
  end
end
