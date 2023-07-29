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

    previously_validated_protocols = Protocol.where(rmid_validated: true)
    previously_validated_count = previously_validated_protocols.count
    previously_validated_ids = previously_validated_protocols.map(&:id)

    validated_rmid_count = 0

    newly_validated_count = 0
    newly_validated_ids = []

    removed_validation_count = 0
    removed_validation_ids = []

    puts("Initial data cleanup...")
    puts('  Fetching from Research Master API...')

    research_masters = HTTParty.get(
      "#{Setting.get_value('research_master_api')}research_masters.json",
      headers:{
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=\"#{Setting.get_value('rmid_api_token')}\""
      }
    )

    all_rm_ids = research_masters.map{|rmid| rmid['id']}

    protocols_to_cleanup = Protocol.where.not(research_master_id: nil).where.not(research_master_id: all_rm_ids) # we have an research_master_id but it doesn't exist in the RMID system
    
    cleanup_count = protocols_to_cleanup.count
    cleanup_ids = protocols_to_cleanup.map(&:id)
   
    protocols_to_cleanup.update_all(research_master_id: nil)
  
    puts("  Research Master ID removed from: #{cleanup_count} Protocols")
    puts("  IDs: #{cleanup_ids}\n")

    # beginning validation of protocols with a valid research_master_id
    puts("Research Master validation...")

    puts('  Fetching from Research Master API...')
    validated_research_masters = HTTParty.get(
      "#{Setting.get_value('research_master_api')}validated_records.json",
      headers:{
        'Content-Type' => 'application/json',
        'Authorization' => "Token token=\"#{Setting.get_value('rmid_api_token')}\""
      }
    )

    validated_rmid_count = validated_research_masters.count
    validated_rmid_ids = validated_research_masters.map{|rm| rm['id']}

    puts("  Beginning data refresh...")
    puts("  Total number of validated Research Masters from Research Master API: #{validated_rmid_count}")

    progress_bar = ProgressBar.new(validated_rmid_count)

    Protocol.update_all(rmid_validated: false) # clear all validation and redo, we saved previous count so we can determine how many have been removed

    validated_research_masters.each do |vrm|
      if protocol = Protocol.find_by_research_master_id(vrm['id'])

        # update attributes but don't perform validation
        protocol.short_title = vrm['short_title']
        protocol.title = vrm['long_title']
        protocol.rmid_validated = true
        protocol.save(validate: false)

        if protocol.has_human_subject_info? && protocol.human_subjects_info.irb_records.any?
          protocol
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

        newly_validated_count += 1
        newly_validated_ids << protocol.id
      end
      progress_bar.increment!
    end

    removed_validation_count = [previously_validated_count - newly_validated_count, 0].max # return 0 for negative number
    removed_validation_ids = previously_validated_ids - newly_validated_ids

    puts("\n\nChecking existing validated protocols against current list...")
    puts("  Previously flagged protocols: #{previously_validated_count}")
    puts("  Number validated via Research Master APIi: #{newly_validated_count}")
    puts("  Validated flag removed from: #{removed_validation_count} Protocols")
    puts("  IDs: #{removed_validation_ids}")

    slack_webhook = Setting.get_value("epic_user_api_error_slack_webhook")
    if slack_webhook.present?
      notifier = Slack::Notifier.new(slack_webhook)
      message =  "RMID update has been performed for SPARC in: #{Rails.env}"
      message += "\nrmid_validated flags removed: #{removed_validation_count}\n"
      message += "\nProtocol IDs: #{removed_validation_ids}\n"
      message += "\nresearch_master_ids removed: #{cleanup_count}\n"
      message += "\nProtocol IDs: #{cleanup_ids}\n"
      notifier.ping(message)
    end

    teams_webhook = Setting.get_value("epic_user_api_error_teams_webhook")
    if teams_webhook.present?
      message =  "RMID update has been performed for SPARC in: #{Rails.env}\n"
      message += "\nrmid_validated flags removed: #{removed_validation_count}\n"
      message += "\nProtocol IDs: #{removed_validation_ids}\n"
      message += "\nresearch_master_ids removed: #{cleanup_count}\n"
      message += "\nProtocol IDs: #{cleanup_ids}\n"
      notifier = Teams.new(teams_webhook)
      notifier.post(message)
    end
  end
end

