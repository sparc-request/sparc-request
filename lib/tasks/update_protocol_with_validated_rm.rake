# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

require 'progress_bar'

desc 'Updating Protocol with validated Research Master information'
namespace :data do
  task update_protocol_with_validated_rm: :environment do
    print('Fetching from Research Master API...')
    validated_research_masters = HTTParty.get(
      "#{Setting.find_by_key('research_master_api_url').value}validated_records.json",
      headers:{
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=\"#{Setting.find_by_key('research_master_api_token').value}\""
      }
    )
    puts 'Done'

    puts("\n\nBeginning data refresh...")
    puts(
      "Total number of validated Research Masters from RM API:
      #{validated_research_masters.count}"
    )

    progress_bar = ProgressBar.new(validated_research_masters.count)

    validated_research_masters.each do |vrm|
      if Protocol.exists?(research_master_id: vrm['id'])
        protocol_to_update = Protocol.find_by(research_master_id: vrm['id'])
        protocol_to_update.update_attributes(
          short_title: vrm['short_title'],
          title: vrm['long_title'],
          rmid_validated: true
        )
        if protocol_to_update.has_human_subject_info?
          protocol_to_update
            .human_subjects_info
            .update_attribute(:pro_number, vrm['pro_number'])
        end
      end
      progress_bar.increment!
    end
  end
end

