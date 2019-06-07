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

namespace :data do 
  task :update_protocol_info_pushed_to_epic => :environment do
    CSV.open("tmp/bad_data_protocols.csv", "wb") do |csv|
      csv << ["Protocol ID", "Last Epic Push Time", "Last Epic Push Status", "Updated_at", "Created_at", "Selected For Epic", "Study Type Question Group ID"]

      epic_interface = EPIC_INTERFACE

      Protocol.where(last_epic_push_status: 'complete').each do |protocol|
        # Check added per Wenjun 3/21/18
        if protocol.selected_for_epic
          if protocol.study_type_answers.empty?
            csv << [protocol.id, protocol.last_epic_push_time, protocol.last_epic_push_status, protocol.updated_at, protocol.created_at, protocol.selected_for_epic, protocol.study_type_question_group_id]
            puts "Bad data protocol #{protocol.id}"
          else
            epic_interface.send_study_creation(protocol)
            puts "Updated protocol #{protocol.id}"
          end
        else
          puts "Protocol is not selected for epic #{protocol.id}"
        end
      end
    end
    puts "This script created tmp/bad_data_protocols.csv"
  end
end
