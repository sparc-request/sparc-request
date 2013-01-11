class Charge::ObisEntitySerializer
  def as_json(charge, options = nil)
    return [
      charge.service.obisid,
      charge.charge_amount.to_f
    ]
  end

  def update_from_json(charge, h, options = nil)
    service = Service.find_by_obisid(h[0])
    raise ArgumentError, "Could not find service with id #{h[0]}" if not service

    charge.update_attributes!(
        service_id: service.id,
        charge_amount: h[1])
  end
end

class Charge
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

