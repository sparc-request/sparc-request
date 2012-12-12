class SubServiceRequest::ObisEntitySerializer
  def as_json(ssr, options = nil)
    h = {
      'id'             => ssr.ssr_id,
      'past_statuses'  => ssr.past_statuses.as_json(options),
      'status'         => ssr.status,
      'status_date'    => ssr.status_date.try(:strftime, '%F %T'),
    }

    h.delete_if { |k, v| v.blank? }

    if ssr.organization then
      type = ssr.organization.type.downcase
      h["#{type}_id"] = ssr.organization.obisid
    end

    return h
  end

  def update_from_json(ssr, h, options = nil)
    organization_obisid = h['core_id'] || 
                          h['program_id'] ||
                          h['provider_id'] ||
                          h['institution_id']

    if organization_obisid then
      organization = Organization.find_by_obisid(organization_obisid)
      if not organization then
        raise ArgumentError, "Could not find organization with obisid #{organization_obisid}"
      end

      ssr.update_attribute(:organization_id, organization.id)
    end

    ssr.update_attributes!(
        ssr_id:           h['id'],
        status:           h['status'],
        status_date:      h['status_date'] ? Time.parse(h['status_date']) : nil)

    # Delete all past statuses for the sub service request; they will be
    # re-created in the next step.
    ssr.past_statuses.each do |past_status|
      past_status.destroy()
    end

    # Create a new past status for each one that is passed in.
    (h['past_statuses'] || { }).each do |h_past_status|
      past_status = ssr.past_statuses.create()
      past_status.update_from_json(h_past_status, options)
    end
  end
end

class SubServiceRequest
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

