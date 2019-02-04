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
  task fix_past_status_data: :environment do
    status_list_post_submission = ['ctrc_approved', 'administrative_review', 'approved', 'awaiting_pi_approval', 'complete', 'declined', 'invoiced', 'ctrc_review', 'committee_review', 'fulfillment_queue', 'in_process', 'on_hold', 'submitted', 'withdrawn', 'incomplete']
    status_list_pre_submission  = ['draft', 'first_draft', 'get_a_cost_estimate']

    CSV.open("tmp/update_submitted_at_and_past_status_data_#{Time.now.strftime('%m%d%Y%H%M%S')}.csv", "wb") do |csv|

      csv << ["Protocol ID", "SSR ID", "Action(s) Taken"]

      csv << ["Fixing ssrs that have been submitted, but have no past_statuses"]
      csv << []
      puts "Creating past_status rows for previously submitted ssrs, that don't have any past_status rows"

      list = SubServiceRequest.left_outer_joins(:past_statuses).where(past_statuses: {sub_service_request_id: nil}).where.not(status: status_list_pre_submission)
      first_bar = ProgressBar.new(list.size)
      list.each do |ssr|
        ssr.past_statuses.create(status: 'draft', new_status: ssr.status, date: ssr.created_at)
        csv << [ssr.protocol_id, ssr.id, "Added past_status for draft => current status"]
        first_bar.increment!
      end

      csv << []
      csv << []
      csv << []
      csv << ["Fixing all other ssrs with problems"]
      csv << []
      puts "Fixing all other records"

      second_bar = ProgressBar.new(SubServiceRequest.joins(:past_statuses).where(past_statuses: {new_status: status_list_post_submission}).or(SubServiceRequest.joins(:past_statuses).where(status: status_list_post_submission)).distinct.size)
      SubServiceRequest.joins(:past_statuses).where(past_statuses: {new_status: status_list_post_submission}).or(SubServiceRequest.joins(:past_statuses).where(status: status_list_post_submission)).distinct.find_each(batch_size: 500) do |ssr|

        ## Skip any that aren't missing either data point
        if (ssr.past_statuses.where(status: status_list_pre_submission, new_status: 'submitted').any? && !ssr.submitted_at.nil?)
          second_bar.increment!
          next
        end

        #Find first time an ssr moved from a pre-submission, to a post-submission status.
        last_pre_submission_status = ssr.past_statuses.sort_by(&:date).detect{|past_status| status_list_pre_submission.include?(past_status.status) && status_list_post_submission.include?(past_status.new_status) }
        first_post_submission_status = ssr.past_statuses.sort_by(&:date).detect{|past_status| status_list_post_submission.include?(past_status.status) }


        ##Correct bad data, where there are no PRE-submission past_statuses, only post-submission past statuses
        if last_pre_submission_status.nil?
          if ssr.submitted_at
            ##Use ssr submitted at, if available.
            submission_date = ssr.submitted_at
          else
            ##Use first post submission past status, minus one second.
            submission_date = (first_post_submission_status.date - 1.second)
          end
          last_pre_submission_status = ssr.past_statuses.create(status: 'draft', date: submission_date, new_status: (first_post_submission_status ? first_post_submission_status.status : ssr.status))
          csv << [ssr.protocol_id, ssr.id, "No pre-submission past status found, created one to fix bad data"]
        end

        if ssr.submitted_at.nil?
          if ( submitted_past_status = ssr.past_statuses.detect{|past_status| past_status.new_status == "submitted"} )

            ##Only submitted_at needs to be populated.
            ssr.update_attribute(:submitted_at, submitted_past_status.date)
            csv << [ssr.protocol_id, ssr.id, "Submitted_at on ssr set, based on past_status information."]
          else
            ##Submitted_at needs to be populated, AND a past_status needs to be created, to match, based on existing past status data, and existing past_status rows on either side need updated.

            #Set ssr.submitted_at
            ssr.update_attribute(:submitted_at, last_pre_submission_status.date)

            #Create new past_status row for from submission
            ssr.past_statuses.create(status: "submitted", new_status: (first_post_submission_status ? first_post_submission_status.status : ssr.status), date: last_pre_submission_status.date)

            #Update previous past_status to reference new row
            last_pre_submission_status.update_attribute(:new_status, "submitted")

            if first_post_submission_status
              #Update next past_status to reference new row, if it exists.
              first_post_submission_status.update_attribute(:status, "submitted")
            end

            csv << [ssr.protocol_id, ssr.id, "Submitted_at on ssr set, and past_status row created to match, and existing past_status rows adjusted to reference new row."]
          end
        else
          ##Past Status needs created, to match existing submitted_at date if possible.
          if first_post_submission_status
            submission_date = (first_post_submission_status.date >= ssr.submitted_at ? ssr.submitted_at : last_pre_submission_status.date)
          else
            submission_date = ssr.submitted_at
          end
          ssr.past_statuses.create(status: last_pre_submission_status.status, new_status: "submitted", date: submission_date)
          ##Update previous past_status to reference new row.
          last_pre_submission_status.update_attribute(:status, "submitted")
          csv << [ssr.protocol_id, ssr.id, "New Past Status row created, using submitted_at date, if applicable."]
        end
        second_bar.increment!
      end
    end
  end
end
