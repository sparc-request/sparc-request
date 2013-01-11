class Fulfillment::ObisEntitySerializer
  def as_json(fulfillment, options = nil)
    h = {
      'notes' => fulfillment.notes,
      'time' => fulfillment.time,
      'timeframe' => fulfillment.timeframe,
    }

    if fulfillment.date then
      h['date'] = fulfillment.date.strftime('%Y-%m-%d')
    end

    return h
  end

  def update_from_json(visit, h, options = nil)
    visit.update_attributes!(
        notes:     h['notes'],
        time:      h['time'],
        timeframe: h['timeframe'],
        date:      legacy_parse_date(h['date']))
  end
end

class Fulfillment
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end
