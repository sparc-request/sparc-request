class Fulfillment < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :line_item

  attr_accessible :line_item_id
  attr_accessible :timeframe
  attr_accessible :notes
  attr_accessible :time
  attr_accessible :date

  # TODO: order by date/id instead of just by date?
  default_scope :order => 'id ASC'

  QUANTITY_TYPES = ['Min', 'Hours', 'Days', 'Each']
end

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
