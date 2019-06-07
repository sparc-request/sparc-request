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

desc "Remove or update SR in first_draft status"
task :remove_or_update_SR_in_first_draft_status => :environment do
  Rails.application.eager_load!

  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = false
    end
  end

  ServiceRequest.skip_callback(:save, :after, :set_original_submitted_date)

  CSV.open("tmp/remove_or_update_SR.csv", "wb") do |csv|

    csv << [""]
    csv << [""]

    csv << ["Action", "Protocol ID", "SR ID", "SR submitted_at", "SR original_submitted_date","SR Status", "SR UPDATED Status", "SR UPDATED submitted_at", "SR UPDATED original_submitted_date","SSR ID(s)", "SSR submitted_at", "SSR Status(s)"]

    protocols_with_no_ssrs = (Protocol.joins(:service_requests).where(service_requests: {status:  "first_draft"}).uniq - Protocol.joins(service_requests: :sub_service_requests).where(service_requests: {status:  "first_draft"}).uniq)

    protocols_with_ssrs = Protocol.joins(service_requests: :sub_service_requests).where(service_requests: {status:  "first_draft"}).uniq

    # If SR doesn't have any associated SSRs, delete both the SR and the Protocol.
    protocols_with_no_ssrs.each do |protocol|
      service_requests = protocol.service_requests
      csv << ["REMOVED", protocol.id, service_requests.map(&:id).first, service_requests.map(&:submitted_at).first.try(:to_date), service_requests.map(&:original_submitted_date).first.try(:to_date), service_requests.first.status]

      # Destroy SRs
      service_requests.each do |sr|
        puts "Destroyed SR #{sr.id}"
        sr.destroy
      end
      puts "Destroyed Protocol #{protocol.id}"
      protocol.reload
      # Destroy Protocol
      protocol.destroy
    end

    protocols_with_ssrs.each do |protocol|

      sub_service_requests = protocol.sub_service_requests

      service_requests = sub_service_requests.map(&:service_request).uniq
      service_requests.each do |sr|
        
        ssr_statuses = sub_service_requests.map(&:status).uniq
         # If the SR has associated SSRs all with "draft" status, then change the SR status to "draft"
        if ssr_statuses.first == 'draft' && ssr_statuses.count == 1
          csv << ["UPDATED SR TO DRAFT STATUS", protocol.id, sr.id, sr.submitted_at.try(:to_date), sr.original_submitted_date.try(:to_date), sr.status]
          sr.update_attributes(status: 'draft')
          sr.save(validate: false)
          puts "Updated SR #{sr.id}"
        # Change SR status to "submitted" and change SR submitted_at date and original_submitted_at date
        # Look at the SSRs submitted_at dates as well as the SR submitted_at date (if applicable).  Choose the latest one for the SR submited_at date and the oldest one for the original_sumibbted_at date.
        elsif sr.submitted_at.present?
          sub_service_requests_with_submitted_at_date = sub_service_requests.where(status: ["complete", "submitted"]).reject{ |i| i.submitted_at.nil? }
          # Find SSR with the most recent submitted_at date
          most_recently_submitted_at_ssr = sub_service_requests_with_submitted_at_date.max_by { |i| i[:submitted_at] }
          # Find SSR with the oldest submitted_at date
          oldest_submitted_at_ssr = sub_service_requests_with_submitted_at_date.min_by { |i| i[:submitted_at] }     

          csv << ["UPDATED", protocol.id, sr.id, sr.submitted_at.try(:to_date), sr.original_submitted_date.try(:to_date), sr.status]

          sr.update_attributes(status: 'submitted')

          
          # Update SR to the most recent submitted_at date
          if (most_recently_submitted_at_ssr.submitted_at) > (sr.submitted_at)
            sr.update_attributes(submitted_at: most_recently_submitted_at_ssr.submitted_at)
          end

          # Update SR to the most recent submitted_at date
          if (sr.submitted_at) < (oldest_submitted_at_ssr.submitted_at)
            sr.update_attributes(original_submitted_date: sr.submitted_at)
          else
            sr.update_attributes(original_submitted_date: oldest_submitted_at_ssr.submitted_at)
          end

          sr.save(validate: false)
          puts "Updated SR #{sr.id}"
        elsif sr.submitted_at.nil? && sub_service_requests.map(&:submitted_at).compact.empty?
          # If SR and SSRS do not have submitted_at dates, leave the SR and SSR dates blank, and change the SR to Draft 
          csv << ["UPDATED (SR & SSRS had no submitted_at dates)", protocol.id, sr.id, sr.submitted_at.try(:to_date), sr.original_submitted_date.try(:to_date), sr.status]
          sr.update_attributes(status: 'draft')
          sr.save(validate: false)
          puts "Updated SR #{sr.id}"
        else
          puts "Do not have a solution for SR #{sr.id}"
        end
      end
      sub_service_requests.each do |ssr|
        service_request = ssr.service_request
        service_request.reload
        ssr.reload
        csv << ['','', '', '', '', '', service_request.status, service_request.submitted_at.try(:to_date), service_request.original_submitted_date.try(:to_date), ssr.id, ssr.submitted_at.try(:to_date), ssr.status]
      end
    end
  end
  ActiveRecord::Base.descendants.each do |model|
    if model.respond_to? 'auditing_enabled'
      model.auditing_enabled = true
    end
  end
end

