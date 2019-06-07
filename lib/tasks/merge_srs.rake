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

require 'progress_bar'

AUDIT_COMMENT = "merge_srs"

task :merge_srs => :environment do
  ServiceRequest.skip_callback(:save, :after, :set_original_submitted_date)

  multiple_ssrs_fp = CSV.open("tmp/multiple_ssrs.csv", "w")

  multiple_ssrs_fp << ['Protocol ID', 'short title', 'ssr_id', 'Organization ID', 'Organization Name', 'SSR status', 'SSR pushed to Fulfillment?', 'SR ID', 'SR Submission date']

  protocols = Protocol.joins(:service_requests).group('protocols.id').having('count(protocol_id) >= 2').to_a

  bar1 = ProgressBar.new(protocols.count)
  protocols.each do |protocol|

    # Grab SSR's
    sub_service_requests = protocol.sub_service_requests

    # If we have multiple SSR's
    if sub_service_requests.count > 1
      # Log them and any other SSR's with multiplicity
      protocol.sub_service_requests.group_by(&:organization_id).each do |organization_id, ssrs|
        next unless ssrs.count > 1
        ssrs.each do |ssr|
          multiple_ssrs_fp << [protocol.id, protocol.short_title, ssr.ssr_id,
            ssr.organization_id, ssr.organization.name, ssr.status,
            ssr.in_work_fulfillment?, ssr.service_request_id,
            ssr.service_request.submitted_at]
        end
      end
    end

    bar1.increment!
  end

  multiple_ssrs_fp.close

  protocols = Protocol.joins(:service_requests).group('protocols.id').having('count(protocol_id) >= 2').to_a
  bar2 = ProgressBar.new(protocols.count)
  protocols.each do |protocol|

    # Merge remaining service requests into service request with most recently
    # updated status
    recent_service_request = protocol.service_requests.preload(:audits).distinct.map do |sr|
      last_status_change = sr.audits.reverse.find { |a| a.audited_changes["status"] }
      if last_status_change
        [sr, last_status_change.created_at]
      end
    end.compact.sort do |l, r|
      l[1] <=> r[1]
    end

    recent_service_request = if recent_service_request.empty?
      # If audit trail runs out, use most recently updated ServiceRequest
      protocol.service_requests.order(:updated_at).last
    else
      recent_service_request.last[0]
    end

    # And the latest submitted_at date
    latest_submitted_at = protocol.service_requests.
      order(:submitted_at).
      where.not(submitted_at: nil).
      pluck(:submitted_at).
      last

    if latest_submitted_at
      recent_service_request.submitted_at = latest_submitted_at
      recent_service_request.audit_comment = AUDIT_COMMENT
      recent_service_request.save(validate: false)
    end

    # Keep the earliest original_submitted_date among service requests
    earliest_original_submitted_date = protocol.service_requests.
      order(:original_submitted_date).
      where.not(original_submitted_date: nil).
      pluck(:original_submitted_date).
      first

    if earliest_original_submitted_date
      recent_service_request.original_submitted_date = earliest_original_submitted_date
      recent_service_request.audit_comment = AUDIT_COMMENT
      recent_service_request.save(validate: false)
    end

    # Move all SSR's, LineItems and ServiceRequest Notes under this recent_service_request
    protocol.sub_service_requests.where.not(service_request_id: recent_service_request.id).each do |ssr|
      ssr.service_request_id = recent_service_request.id
      ssr.audit_comment = AUDIT_COMMENT
      ssr.save(validate: false)
    end
    line_items = LineItem.joins(:service_request).where(service_requests: { protocol_id: protocol.id }).where.not(service_request_id: recent_service_request.id)
    line_items.each do |li|
      li.service_request_id = recent_service_request.id
      li.audit_comment = AUDIT_COMMENT
      li.save(validate: false)
    end

    protocol.service_requests.where.not(id: recent_service_request.id).each do |sr|
      sr.notes.each do |note|
        note.notable_id = recent_service_request.id
        note.audit_comment = AUDIT_COMMENT
        note.save(validate: false)
      end
    end

    delete_empty_srs(protocol)

    bar2.increment!
  end

  record_odd_balls
end

def delete_empty_srs(protocol)
  protocol.service_requests.includes(:sub_service_requests).where(sub_service_requests: { id: nil }).each do |sr|
    begin
      sr.destroy
      sr.audits.last.update(comment: AUDIT_COMMENT)
    rescue
      # Probably a funky Note body...
      sr.notes.each do |note|
        note.notable_id = nil
        note.audit_comment = AUDIT_COMMENT
        note.save(validate: false)
      end
      sr.reload.destroy
      sr.audits.last.update(comment: AUDIT_COMMENT)
    end
  end
  
  # If we still have multiple service request we have a problem
  def record_odd_balls
    protocols = Protocol.joins(:service_requests).group('protocols.id').having('count(protocol_id) >= 2').to_a

    if protocols.count != 0
      puts 'Oops, found some oddballs.'
      protocols.each do |protocol|
        puts "Protocol ID: #{protocol.id}"
      end
    end
  end
end
