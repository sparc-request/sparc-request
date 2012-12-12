class PricingMap::ObisEntitySerializer
  def as_json(pricing_map, options = nil)
    h = {
      'unit_minimum'               => pricing_map.unit_minimum,
      'is_one_time_fee'            => pricing_map.is_one_time_fee,
      'full_rate'                  => pricing_map.full_rate.to_f,
      'unit_factor'                => pricing_map.unit_factor.to_f,
      'unit_type'                  => pricing_map.unit_type,
    }

    optional = {
      'effective_date'             => pricing_map.effective_date.try(:strftime, '%Y-%m-%d'),
      'display_date'               => pricing_map.display_date.try(:strftime, '%Y-%m-%d'),
      'corporate_rate'             => pricing_map.corporate_rate ? pricing_map.corporate_rate.to_f : nil,
      'federal_rate'               => pricing_map.federal_rate   ? pricing_map.federal_rate.to_f   : nil,
      'member_rate'                => pricing_map.member_rate    ? pricing_map.member_rate.to_f    : nil,
      'other_rate'                 => pricing_map.other_rate     ? pricing_map.other_rate.to_f     : nil,
      'percent_of_fee'             => pricing_map.percent_of_fee ? pricing_map.percent_of_fee.to_f : nil,
      'exclude_from_indirect_cost' => pricing_map.exclude_from_indirect_cost,
    }

    optional.delete_if { |k, v| v.nil? }

    h.update(optional)

    return h
  end

  def update_from_json(pricing_map, h, options = nil)
    pricing_map.update_attributes!(
        :unit_minimum               => h['unit_minimum'],
        :is_one_time_fee            => h['is_one_time_fee'],
        :percent_of_fee             => h['percent_of_fee'],
        :effective_date             => h['effective_date'],
        :display_date               => h['display_date'],
        :full_rate                  => h['full_rate'],
        :unit_factor                => h['unit_factor'],
        :unit_type                  => h['unit_type'],
        :corporate_rate             => h['corporate_rate'],
        :federal_rate               => h['federal_rate'],
        :member_rate                => h['member_rate'],
        :other_rate                 => h['other_rate'],
        :exclude_from_indirect_cost => h['exclude_from_indirect_cost'])
  end
end

class PricingMap
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

