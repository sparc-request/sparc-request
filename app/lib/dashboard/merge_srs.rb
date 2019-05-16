module Dashboard

  class MergeSrs

    def perform_sr_merge
      ServiceRequest.skip_callback(:save, :after, :set_original_submitted_date)

      protocols = Protocol.joins(:service_requests).group('protocols.id').having('count(protocol_id) >= 2').to_a
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
          recent_service_request.audit_comment = 'merge_srs'
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
          recent_service_request.audit_comment = 'merge_srs'
          recent_service_request.save(validate: false)
        end

        # Move all SSR's, LineItems and ServiceRequest Notes under this recent_service_request
        protocol.sub_service_requests.where.not(service_request_id: recent_service_request.id).each do |ssr|
          ssr.service_request_id = recent_service_request.id
          ssr.audit_comment = 'merge_srs'
          ssr.save(validate: false)
        end
        line_items = LineItem.joins(:service_request).where(service_requests: { protocol_id: protocol.id }).where.not(service_request_id: recent_service_request.id)
        line_items.each do |li|
          li.service_request_id = recent_service_request.id
          li.audit_comment = 'merge_srs'
          li.save(validate: false)
        end

        protocol.service_requests.where.not(id: recent_service_request.id).each do |sr|
          sr.notes.each do |note|
            note.notable_id = recent_service_request.id
            note.audit_comment = 'merge_srs'
            note.save(validate: false)
          end
        end

        delete_empty_srs(protocol)
      end

      ServiceRequest.set_callback(:save, :after, :set_original_submitted_date)
    end

    private

    def delete_empty_srs(protocol)
      protocol.service_requests.includes(:sub_service_requests).where(sub_service_requests: { id: nil }).each do |sr|
        begin
          sr.destroy
          sr.audits.last.update(comment: 'merge_srs')
        rescue
          # Probably a funky Note body...
          sr.notes.each do |note|
            note.notable_id = nil
            note.audit_comment = 'merge_srs'
            note.save(validate: false)
          end
          sr.reload.destroy
          sr.audits.last.update(comment: 'merge_srs')
        end
      end
    end
  end
end
