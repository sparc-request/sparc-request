# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

require 'json'

namespace :data do
  desc "Import historical eIRB dates from RMID using the eIRB Pro Number"
  task import_eirb_data: :environment do

    if Setting.get_value('research_master_enabled')
      puts 'Fetching from Research Master API...'
      protocols = HTTParty.get(
        "#{Setting.get_value('research_master_api')}protocols.json?type=EIRB",
        headers:{
          'Content-Type' => 'application/json',
          'Authorization' => "Token token=\"#{Setting.get_value('rmid_api_token')}\""
        }
      ).parsed_response.reject{ |rm| rm['eirb_id'].blank? }

      research_masters = HTTParty.get(
        "#{Setting.get_value('research_master_api')}research_masters.json",
        headers:{
          'Content-Type' => 'application/json',
          'Authorization' => "Token token=\"#{Setting.get_value('rmid_api_token')}\""
        }
      ).parsed_response
      
      puts "Done"

      puts "\n\nBeginning data import"

      records_changed = 0

      ActiveRecord::Base.transaction do
        CSV.open("tmp/#{Date.today}_historical_protocols_missing_rmids_report.csv", "wb") do |csv|
          csv << ["SPARC Protocol ID", "eIRB Pro Number", "Match Found", "Recommended Research Master ID", "Initial Approval Date", "Approval Date", "Expiration Date"]
          Protocol.joins(:human_subjects_info).where(research_master_id: nil).where.not(human_subjects_info: { pro_number: [nil,""] }).each do |protocol|
            rmid_record = protocols.detect{ |p| pro_matches?(protocol.human_subjects_info.pro_number, p['eirb_id']) }

            csv << [
              protocol.id.to_s,
              protocol.human_subjects_info.pro_number,
              rmid_record ? "Yes" : "No",
              rmid_record ? research_masters.detect{ |rm| rm['eirb_pro_number'] == rmid_record['eirb_id'] }.try(:[], 'id') : "",
              rmid_record ? rmid_record['date_initially_approved']  : protocol.human_subjects_info.initial_irb_approval_date,
              rmid_record ? rmid_record['date_approved']            : protocol.human_subjects_info.irb_approval_date,
              rmid_record ? rmid_record['date_expiration']          : protocol.human_subjects_info.irb_expiration_date
            ]

            if rmid_record
              protocol.human_subjects_info.update_attributes(
                pro_number:                 rmid_record['eirb_id'],
                initial_irb_approval_date:  rmid_record['date_initially_approved'],
                irb_approval_date:          rmid_record['date_approved'],
                irb_expiration_date:        rmid_record['date_expiration']
              )

              records_changed += 1
            else
              protocol.human_subjects_info.update_attributes(
                initial_irb_approval_date:  nil,
                irb_approval_date:          nil,
                irb_expiration_date:        nil
              )
            end
          end
        end
      end

      puts "Done"
      puts "\n\n#{records_changed} records were updated"
      puts "\n\nA list of all updated records and recommended Research Master IDs can be found in tmp/#{Date.today}_historical_protocols_missing_rmids_report.csv"
    else
      puts "Research Master ID must be turned on. Aborting..."
    end
  end
end

def pro_matches?(old_val, new_val)
  return false unless old_val && new_val

  old_val = old_val.strip.gsub(/\A((I|i)(R|r)(B|b):?\s*)?((P|p)(R|r)(O|o|0))?\s*0+|\z/, '')
  new_val = new_val.strip.gsub(/\A((I|i)(R|r)(B|b):?\s*)?((P|p)(R|r)(O|o|0))?\s*0+|\z/, '')

  old_val == new_val
end
