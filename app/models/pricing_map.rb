class PricingMap < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service

  attr_accessible :service_id
  attr_accessible :unit_type
  attr_accessible :unit_factor
  attr_accessible :percent_of_fee
  attr_accessible :is_one_time_fee
  attr_accessible :full_rate
  attr_accessible :exclude_from_indirect_cost
  attr_accessible :unit_minimum
  attr_accessible :units_per_qty_max
  attr_accessible :federal_rate
  attr_accessible :corporate_rate
  attr_accessible :other_rate
  attr_accessible :member_rate
  attr_accessible :effective_date
  attr_accessible :display_date

  # Determines the rate for a particular service.
  #
  # +default_percentage+:: a number between 0 and 1
  #
  # +rate_type+:: a string representing the rate type (e.g. federal,
  # corporate, member, or other)
  #
  # Returns the rate as an integer number of cents.
  def applicable_rate(rate_type, default_percentage)
    rate = rate_override(rate_type)
    rate ||= calculate_rate(default_percentage)
    return rate
  end

  # Determine the rate override for a given rate type
  #
  # +rate_type+:: a string representing the rate type (e.g. federal,
  # corporate, member, or other)
  def rate_override(rate_type)
    return case rate_type
    when 'federal'    then self.federal_rate
    when 'corporate'  then self.corporate_rate
    when 'member'     then self.member_rate
    when 'other'      then self.other_rate
    else raise ArgumentError, "Could not find rate for #{rate_type}"
    end
  end

  # Calculate the rate for a particular service based on the percents in
  # the pricing setup.
  #
  # +default_percentage+:: a number between 0 and 1
  #
  # Returns an integer number of cents.
  def calculate_rate(default_percentage)
    return self.full_rate.to_f * default_percentage
  end

  def self.rates_from_full date, organization_id, full_rate
    organization  = Organization.find(organization_id)
    pricing_setup = organization.pricing_setup_for_date(date)
    federal       = (full_rate * (pricing_setup.federal   / 100)).to_f
    corporate     = (full_rate * (pricing_setup.corporate / 100)).to_f
    member        = (full_rate * (pricing_setup.member    / 100)).to_f
    other         = (full_rate * (pricing_setup.other     / 100)).to_f
    rate_hash     = { federal_rate: federal, corporate_rate: corporate, member_rate: member,
                      other_rate: other }

    return rate_hash
  end
end
