class PricingSetup::ObisEntitySerializer
  def as_json(pricing_setup, options = nil)
    h = {
      'display_date' => pricing_setup.display_date.try(:strftime, '%Y-%m-%d'),
      'effective_date' => pricing_setup.effective_date.try(:strftime, '%Y-%m-%d'),
      'charge_master' => pricing_setup.charge_master,
      'federal' => pricing_setup.federal,
      'corporate' => pricing_setup.corporate,
      'other' => pricing_setup.other,
      'member' => pricing_setup.member,
      'college_rate_type' => pricing_setup.college_rate_type,
      'federal_rate_type' => pricing_setup.federal_rate_type,
      'foundation_rate_type' => pricing_setup.foundation_rate_type,
      'industry_rate_type' => pricing_setup.industry_rate_type,
      'investigator_rate_type' => pricing_setup.investigator_rate_type,
      'internal_rate_type' => pricing_setup.internal_rate_type,
    }
    return h
  end

  def update_from_json(pricing_setup, h, options = nil)
    pricing_setup.update_attributes!(
        :display_date => h['display_date'],
        :effective_date => h['effective_date'],
        :charge_master => h['charge_master'],
        :federal => h['federal'],
        :corporate => h['corporate'],
        :other => h['other'],
        :member => h['member'],
        :college_rate_type => h['college_rate_type'],
        :federal_rate_type => h['federal_rate_type'],
        :foundation_rate_type => h['foundation_rate_type'],
        :industry_rate_type => h['industry_rate_type'],
        :investigator_rate_type => h['investigator_rate_type'],
        :internal_rate_type => h['internal_rate_type'])
  end

  def self.create_from_json(entity_class, h, options = nil)
    obj = entity_class.create()
    obj.update_from_json(h, options)
    return obj
  end
end

class PricingSetup
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

