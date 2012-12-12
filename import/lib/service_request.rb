class ServiceRequest::ObisEntitySerializer < Entity::ObisEntitySerializer
  def sub_service_requests(service_request, options)
    sub_service_requests = service_request.sub_service_requests.map { |ssr|
      [ ssr.ssr_id, ssr.as_json(options) ]
    }

    return Hash[sub_service_requests]
  end

  def approval_data(service_request, options)
    approval_data = [{
      'approvals'  => Hash[service_request.approvals.as_json(options)],
      'charges'    => Hash[service_request.charges.as_json(options)],
      'tokens'     => Hash[service_request.tokens.as_json(options)],
    }]

    return approval_data
  end

  def subsidies(service_request, options)
    subsidies = service_request.sub_service_requests.map { |ssr| ssr.subsidy }
    return Hash[subsidies.as_json(options)]
  end

  def as_json(srq, options = nil)
    h = super(srq, options)

    h['identifiers'].update(
      'service_request_id'        => srq.id.to_s,
    )

    h['attributes'].update(
      'status'                    => srq.status,
      'line_items'                => srq.line_items.as_json(options),
      'friendly_id'               => srq.id.to_s,
      'sub_service_requests'      => sub_service_requests(srq, options),
      'approval_data'             => approval_data(srq, options),
      'subsidies'                 => subsidies(srq, options),
    )

    optional_attributes = {
      'approved'                  => srq.approved,
      'subject_count'             => srq.subject_count,
      'visit_count'               => srq.visit_count,
      'notes'                     => srq.notes,
      'submitted_at'              => srq.submitted_at.try(:utc)    .try(:strftime, '%F %T %Z'),
      'start_date'                => srq.start_date                .try(:strftime, '%Y-%m-%d'),
      'end_date'                  => srq.end_date                  .try(:strftime, '%Y-%m-%d'),
      'pppv_in_process_date'      => srq.pppv_in_process_date      .try(:strftime, '%Y-%m-%d'),
      'pppv_complete_date'        => srq.pppv_complete_date        .try(:strftime, '%Y-%m-%d'),
      'requester_contacted_date'  => srq.requester_contacted_date  .try(:strftime, '%Y-%m-%d'),
      'consult_arranged_date'     => srq.consult_arranged_date     .try(:strftime, '%Y-%m-%d'),
      'service_requester_id'      => srq.service_requester         .try(:obisid),
    }

    optional_attributes.delete_if { |k, v| v.nil? }

    h['attributes'].update(optional_attributes)

    return h
  end

  def update_attributes_from_json(entity, h, options = nil)
    super(entity, h, options)

    identifiers = h['identifiers']
    attributes = h['attributes']

    # TODO: ignore anything past index 0?
    approval_data_list = h['attributes']['approval_data'] || [ ]
    approval_data = approval_data_list[0] || { }

    if attributes['service_requester_id'] then
      service_requester = Identity.find_by_obisid(attributes['service_requester_id'])
      raise ArgumentError, "Could not find identity with obisid #{attributes['service_requester_id']}" if not service_requester
      service_requester_id = service_requester.id
    else
      service_requester_id = nil
    end

    entity.attributes = {
        :status                    => attributes['status'],
        :approved                  => attributes['approved'],
        :subject_count             => attributes['subject_count'],
        :visit_count               => attributes['visit_count'],
        :notes                     => attributes['notes'],
        :submitted_at              => attributes['submitted_at'] ? Time.parse(attributes['submitted_at']) : nil,
        :start_date                => legacy_parse_date(attributes['start_date']),
        :end_date                  => legacy_parse_date(attributes['end_date']),
        :pppv_in_process_date      => attributes['pppv_in_process_date'],
        :pppv_complete_date        => attributes['pppv_complete_date'],
        :requester_contacted_date  => legacy_parse_date(attributes['requester_contacted_date']),
        :consult_arranged_date     => legacy_parse_date(attributes['consult_arranged_date']),
        :service_requester_id      => service_requester_id
    }
    entity.save!(:validate => false) # TODO

    # Delete all sub service requests for the service request; they will
    # be re-created in the next step.
    entity.sub_service_requests.each do |ssr|
      ssr.destroy()
    end

    # Create a new sub service request for each one that is passed in.
    # Note that this must happen before the line items are
    # created/updated, since line items reference sub service requests.
    attributes['sub_service_requests'].each do |ssr_id, h_sub_service_request|
      sub_service_request = entity.sub_service_requests.create()
      sub_service_request.update_from_json(h_sub_service_request, options)
    end

    # Delete all line items for the service request; they will be
    # re-created in the next step.
    entity.line_items.each do |line_item|
      line_item.destroy()
    end

    # Create a new line item for each one that is passed in.
    attributes['line_items'].each do |h_line_item|
      line_item = entity.line_items.create()
      line_item.update_from_json(h_line_item, options)
    end

    # Delete all approvals for the service request; they will be
    # re-created in the next step.
    entity.approvals.each do |approval|
      approval.destroy()
    end

    # Create a new approval for each one that is passed in.
    (approval_data['approvals'] || { }).each do |h_approval|
      approval = entity.approvals.create()
      approval.update_from_json(h_approval, options)
    end

    # Delete all charges for the service request; they will be
    # re-created in the next step.
    entity.charges.each do |charge|
      charge.destroy()
    end

    # Create a new charge for each one that is passed in.
   (approval_data['charges'] || { }).each do |h_charge|
      charge = entity.charges.create()
      charge.update_from_json(h_charge, options)
    end

    # Delete all tokens for the service request; they will be
    # re-created in the next step.
    entity.tokens.each do |token|
      token.destroy()
    end

    # Create a new charge for each one that is passed in.
    (approval_data['tokens'] || { }).each do |h_token|
      token = entity.tokens.create()
      token.update_from_json(h_token, options)
    end

    # Delete all subsidies for the service request; they will be
    # re-created in the next step.
    entity.sub_service_requests.each do |ssr|
      ssr.subsidy.destroy() if ssr.subsidy
    end

    # Create a new subsidy for each one that is passed in.
    (attributes['subsidies'] || { }).each do |organization_obisid, h_subsidy|
      organization = Organization.find_by_obisid(organization_obisid)
      ssr = entity.sub_service_requests.find_by_organization_id(organization.id)
      subsidy = Subsidy.create(sub_service_request_id: ssr.id)
      subsidy.update_from_json([organization_obisid, h_subsidy], options)
    end
  end

  def self.create_from_json(entity_class, h, options = nil)
    if h['identifiers'] and h['identifiers']['service_request_id'] then
      obj = entity_class.new
      obj.id = h['identifiers']['service_request_id']
      obj.save!(:validate => false) # TODO: shouldn't skip all validations
    else
      obj = entity_class.create()
    end

    obj.update_from_json(h, options)

    return obj
  end

end

class ServiceRequest::ObisSimpleSerializer < Entity::ObisSimpleSerializer
  def as_json(entity, options = nil)
    h = super(entity, options)
    h['project_id'] = entity.protocol.obisid if entity.protocol
    return h
  end

  def self.create_from_json(entity_class, h, options = nil)
    if h['friendly_id'] then
      obj = entity_class.new
      obj.id = h['friendly_id']
      obj.save!
    else
      obj = entity_class.create()
    end

    obj.update_from_json(h, options)

    return obj
  end

  def update_from_json(entity, h, options = { })
    service_request = super(entity, h, options)
    if h['project_id'] then
      protocol = Protocol.find_by_obisid(h['project_id'])
      raise ArgumentError, "Could not find project with obisid #{h['project_id']}" if protocol.nil?
      service_request.update_attribute(:protocol_id, protocol.id)
    end
    return service_request
  end
end

class ServiceRequest
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

