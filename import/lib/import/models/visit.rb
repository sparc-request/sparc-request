class Visit::ObisEntitySerializer
  def as_json(visit, options = nil)
    h = {
      'billing' => visit.billing,
      'quantity' => visit.quantity,
    }

    return h
  end

  def update_from_json(visit, h, options = nil)
    visit.update_attributes!(
        billing:  h['billing'],
        quantity: h['quantity'])
  end
end

class Visit
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

