class LineItem::ObisEntitySerializer
  def as_json(line_item, options = nil)
    h = {
      'optional'                => line_item.optional,
      'quantity'                => line_item.quantity,
      'sub_service_request_id'  => line_item.sub_service_request.ssr_id,
      'visits'                  => line_item.visits.as_json(options),
      'fulfillment'             => line_item.fulfillments.as_json(options), # sic
    }

    optional = {
      'service_id'              => line_item.service.obisid,
      'subject_count'           => line_item.subject_count,
      'in_process_date'         => line_item.in_process_date.try(:strftime, '%Y-%m-%d'),
      'complete_date'           => line_item.complete_date.try(:strftime, '%Y-%m-%d'),
    }

    optional.delete_if { |k, v| v.nil? }

    h.update(optional)

    return h
  end

  def update_from_json(line_item, h, options = nil)
    service = Service.find_by_obisid(h['service_id'])
    raise ArgumentError, "Could not find service with obisid #{h['service_id']}" if not service

    service_request = line_item.service_request
    ssr = service_request.sub_service_requests.find_by_ssr_id(
        h['sub_service_request_id'])

    raise ArgumentError, "Could not find ssr with ssr_id #{h['sub_service_request_id']}" if not ssr

    line_item.update_attributes!(
        optional:                  h['optional'],
        quantity:                  h['quantity'],
        sub_service_request_id:    ssr.id,
        fulfillments:              h['fulfillments'],
        service_id:                service.id,
        subject_count:             h['subject_count'],
        in_process_date:           legacy_parse_date(h['in_process_date']),
        complete_date:             legacy_parse_date(h['complete_date']))

    # Delete all visits for the line item; they will be re-created in
    # the next step.
    line_item.visits.each do |visit|
      visit.destroy()
    end

    # Create a new visit for each one that is passed in.
    (h['visits'] || [ ]).each do |h_visit|
      visit = line_item.visits.create()
      visit.update_from_json(h_visit, options)
    end

    # Delete all fulfillments for the line item; they will be re-created in
    # the next step.
    line_item.fulfillments.each do |fulfillment|
      fulfillment.destroy()
    end

    # Create a new fulfillment for each one that is passed in.
    (h['fulfillment'] || [ ]).each do |h_fulfillment|
      fulfillment = line_item.fulfillments.create()
      fulfillment.update_from_json(h_fulfillment, options)
    end
  end
end

class LineItem
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

