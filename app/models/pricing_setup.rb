class PricingSetup < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :organization

  attr_accessible :organization_id
  attr_accessible :display_date
  attr_accessible :effective_date
  attr_accessible :charge_master
  attr_accessible :federal #o
  attr_accessible :corporate #o
  attr_accessible :other #o
  attr_accessible :member #o
  attr_accessible :college_rate_type
  attr_accessible :federal_rate_type
  attr_accessible :foundation_rate_type
  attr_accessible :industry_rate_type
  attr_accessible :investigator_rate_type
  attr_accessible :internal_rate_type
  
  after_create :create_pricing_maps

  def rate_type(funding_source)
    case funding_source
    when 'college'       then self.college_rate_type
    when 'federal'       then self.federal_rate_type
    when 'foundation'    then self.foundation_rate_type
    when 'industry'      then self.industry_rate_type
    when 'investigator'  then self.investigator_rate_type
    when 'internal'      then self.internal_rate_type
    else raise ArgumentError, "Could not find rate type for funding source #{funding_source}"
    end
  end

  def applied_percentage(rate_type)
    applied_percentage = case rate_type
    when 'federal' then self.federal
    when 'corporate' then self.corporate
    when 'other' then self.other
    when 'member' then self.member
    else raise ArgumentError, "Could not find applied percentage for rate type #{rate_type}"
    end

    applied_percentage = applied_percentage / 100.0 rescue nil

    return applied_percentage || 1.0
  end
  
  def create_pricing_maps
    # If there is no organization, then there are no pricing maps
    return if self.organization.nil?

    self.organization.all_child_services.each do |service|
      begin
        closest_map = PricingMap.new(service.effective_pricing_map_for_date(self.effective_date).attributes)
        closest_map.effective_date = self.effective_date
        closest_map.display_date = self.display_date
        closest_map.save
      rescue
        new_map = service.pricing_maps.build
        new_map.effective_date = self.effective_date
        new_map.display_date = self.display_date
        new_map.full_rate = 0
        new_map.unit_factor = 1
        new_map.unit_minimum = 1
        new_map.unit_type = ""
        new_map.save
      end
    end
  end
end

