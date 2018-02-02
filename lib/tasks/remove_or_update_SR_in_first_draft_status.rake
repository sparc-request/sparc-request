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

desc "Remove or update SR in first_draft status"
task :remove_or_update_SR_in_first_draft_status => :environment do
  ServiceRequest.skip_callback(:save, :after, :set_original_submitted_date)

  CSV.open("tmp/remove_or_update_SR.csv", "wb") do |csv|

    csv << [""]
    csv << [""]

    csv << ["Action", "Protocol ID", "SR ID", "SR submitted_at", "SR original_submitted_date","SR Status", "SR UPDATED Status", "SR UPDATED submitted_at", "SR UPDATED original_submitted_date","SSR ID(s)", "SSR submitted_at", "SSR Status(s)"]

    # If SR doesn't have any associated SSRs, delete both the SR and the Protocol.
    # If the SR has associated SSRs, then change the SR status to "draft" (if all the SSRs have "draft" status) or to "submitted" (if SSRs have conflicting statuses)
    # submitted_at for the SR, look at the SSRs first submission date and record that as SR submission_date. If more than one "submitted" status, choose the earlier one.

    protocols_with_no_ssrs = (Protocol.joins(:service_requests).where(service_requests: {status:  "first_draft"}).uniq - Protocol.joins(service_requests: :sub_service_requests).where(service_requests: {status:  "first_draft"}).uniq)

    protocols_with_ssrs = Protocol.joins(service_requests: :sub_service_requests).where(service_requests: {status:  "first_draft"}).uniq

    protocols_with_no_ssrs.each do |protocol|
      service_requests = protocol.service_requests
      csv << ["REMOVED", protocol.id, service_requests.map(&:id).first, service_requests.map(&:submitted_at).first.try(:to_date), service_requests.map(&:original_submitted_date).first.try(:to_date), service_requests.first.status]
      # Destroy SRs
      service_requests.each do |sr|
        sr.destroy
      end
      protocol.reload
      # Destroy Protocol
      protocol.destroy
    end

    protocols_with_ssrs.each do |protocol|

      sub_service_requests = protocol.sub_service_requests

      service_requests = sub_service_requests.map(&:service_request).uniq
      service_requests.each do |sr|
        
        ssr_statuses = sub_service_requests.map(&:status).uniq
        if ssr_statuses.first == 'draft' && ssr_statuses.count == 1
          csv << ["UPDATED", protocol.id, sr.id, sr.submitted_at.try(:to_date), sr.original_submitted_date.try(:to_date), sr.status]
          sr.update_attributes(status: 'draft')
          sr.save(validate: false)
        elsif sr.submitted_at.present?
          csv << ["UPDATED", protocol.id, sr.id, sr.submitted_at.try(:to_date), sr.original_submitted_date.try(:to_date), sr.status]
          sr.update_attributes(status: 'submitted')
          sr.save(validate: false)
        else
          csv << ["LOOK AT MORE CLOSELY", protocol.id, sr.id, sr.submitted_at.try(:to_date), sr.original_submitted_date.try(:to_date), sr.status]
          # ssrs_that_have_been_submitted = sub_service_requests.where(status: ['complete', 'submitted']).reject{ |ssr| ssr.submitted_at.nil? }
          # submitted_at_dates = ssrs_that_have_been_submitted.map(&:submitted_at).uniq
          # if submitted_at_dates.count == 1
          #   sr.update_attributes(submitted_at: submitted_at_dates)
          #   sr.reload
          # else
          #   ssrs_that_have_been_submitted.map{ |ssr| ssr.submitted_at.try(:strftime, "%Y-%m-%d") }.uniq

          #   ssrs_ordered_by_submitted_at = ssrs_that_have_been_submitted.sort { |a,b| a.submitted_at && b.submitted_at ? a <=> b : a ? -1 : 1 }

          #   # Update the SR's submitted_at to the latest date the SSRs were updated
          #   if ssrs_ordered_by_submitted_at.last.present?
          #     sr.update_attributes(submitted_at: ssrs_ordered_by_submitted_at.last.try(:submitted_at))
          #     sr.update_attributes(status: 'submitted')
          #     sr.save(validate: false)
          #   end
          #   # If the latest date and the first date are not the same, update the original_submitted_at_date of the SR to the earliest submitted_at date
          #   if ssrs_ordered_by_submitted_at.first.try(:submitted_at).try(:strftime, "%Y-%m-%d") !=  ssrs_ordered_by_submitted_at.last.try(:submitted_at).try(:strftime, "%Y-%m-%d")
          #     sr.update_attributes(original_submitted_date: ssrs_ordered_by_submitted_at.first.try(:submitted_at))
          #     sr.update_attributes(status: 'submitted')
          #     sr.save(validate: false)
          #   end
          # end
        end
      end
      sub_service_requests.each do |ssr|
        service_request = ssr.service_request
        service_request.reload
        csv << ['','', '', '', '', '', service_request.status, service_request.submitted_at.try(:to_date), service_request.original_submitted_date.try(:to_date), ssr.id, ssr.submitted_at.try(:to_date), ssr.status]
      end
    end
  end
end

