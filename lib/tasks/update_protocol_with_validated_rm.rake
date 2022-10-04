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

require 'progress_bar'

desc 'Updating Protocol with validated Research Master information'
namespace :data do
  task update_protocol_with_validated_rm: :environment do

    print('Fetching from Research Master API...')
    validated_research_masters = HTTParty.get(
      "#{Setting.get_value('research_master_api')}validated_records.json",
      headers:{
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=\"#{Setting.get_value('rmid_api_token')}\""
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

        # update attributes but don't perform validation
        protocol_to_update.short_title = vrm['short_title']
        protocol_to_update.title = vrm['long_title']
        protocol_to_update.rmid_validated = true
        protocol_to_update.save(validate: false)

        if protocol_to_update.has_human_subject_info? && protocol_to_update.human_subjects_info.irb_records.any?
          protocol_to_update
            .human_subjects_info
            .irb_records
            .first
            .update_attributes(
              pro_number:                 vrm['eirb_pro_number'],
              initial_irb_approval_date:  vrm['date_initially_approved'],
              irb_approval_date:          vrm['date_approved'],
              irb_expiration_date:        vrm['date_expiration']
            )
        end
      end
      progress_bar.increment!
    end

    validated_ids = validated_research_masters.map{|rmid| rmid['id']}

    protocol_count = Protocol.where(rmid_validated: true).count
    puts("\n\nChecking Existing validated protocols against current list:")
    puts("Currently flagged protocols: #{protocol_count}")
    puts("Number from RMID: #{validated_ids.size}")

    bar2 = ProgressBar.new(protocol_count)

    former_validated_protocols = []

    Protocol.where(rmid_validated: true).find_each do |protocol|
      unless validated_ids.include?(protocol.research_master_id)
        protocol.update_attribute(:rmid_validated, false)
        former_validated_protocols << protocol.id
      end

      bar2.increment!
    end

    puts("Validated flag removed from: #{former_validated_protocols.size} Protocols")
    puts("IDs: #{former_validated_protocols}")

    puts ("\n\nChecking non-validated RMID protocols and updated info:")
    print('Fetching from Research Master API...')

    research_masters = HTTParty.get(
      "#{Setting.get_value('research_master_api')}research_masters.json",
      headers:{
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=\"#{Setting.get_value('rmid_api_token')}\""
      }
    )

    rm_ids = research_masters.map{|rmid| rmid['id']}
    non_validated_protocol_count = Protocol.where.not(research_master_id: nil).where(rmid_validated: false).count

    puts("Protocols with rmid info: #{non_validated_protocol_count}")
    puts("Number from RMID: #{research_masters.size}")

    bar3 = ProgressBar.new(non_validated_protocol_count)

    former_rmid_protocols = []

    Protocol.where.not(research_master_id: nil).where(rmid_validated: false).find_each do |non_validated_protocol|
      unless rm_ids.include?(non_validated_protocol.research_master_id)
        non_validated_protocol.update_attribute(:research_master_id, nil)
        former_rmid_protocols << non_validated_protocol.id
      end
      bar3.increment!
    end

    puts("Research Master ID removed from: #{former_rmid_protocols.size} Protocols")
    puts("IDs: #{former_rmid_protocols}")

    slack_webhook = Setting.get_value("epic_user_api_error_slack_webhook")
    if slack_webhook.present?
      notifier = Slack::Notifier.new(slack_webhook)
      message =  "RMID update has been performed for SPARC in: #{Rails.env}"
      message += "\nrmid_validated flags removed: #{former_validated_protocols.size}\n"
      message += "\nProtocol IDs: #{former_validated_protocols}\n"
      message += "\nresearch_master_ids removed: #{former_rmid_protocols.size}\n"
      message += "\nProtocol IDs: #{former_rmid_protocols}\n"
      notifier.ping(message)
    end

  end
end

