class Service < ActiveRecord::Base
  include Entity
  
  #Version.primary_key = 'id'
  #has_paper_trail

  RATE_TYPES = [{:display => "Service Rate", :value => "full"}, {:display => "Federal Rate", :value => "federal"}, {:display => "Corporate Rate", :value => "corporate"}, {:display => "Other Rate", :value => "other"}, {:display => "Member Rate", :value => "member"}]

  belongs_to :organization, :include => [:pricing_setups]
  has_many :pricing_maps, :dependent => :destroy
  has_many :service_providers, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :identities, :through => :service_providers

  # Services that this service depends on
  # TODO: Andrew thinks "related services" is a bad name
  has_many :service_relations, :dependent => :destroy
  has_many :related_services, :through => :service_relations
  has_many :required_services, :through => :service_relations, :source => :related_service, :conditions => [ "optional = ?", false ]
  has_many :optional_services, :through => :service_relations, :source => :related_service, :conditions => [ "optional = ?", true ]

  # Services that depend on this service
  has_many :depending_service_relations, :class_name => 'ServiceRelation', :foreign_key => 'related_service_id'
  has_many :depending_services, :through => :depending_service_relations, :source => :service

  attr_accessible :obisid
  attr_accessible :name
  attr_accessible :abbreviation
  attr_accessible :order
  attr_accessible :description
  attr_accessible :is_available
  attr_accessible :service_center_cost
  attr_accessible :cpt_code
  attr_accessible :charge_code
  attr_accessible :revenue_code
  attr_accessible :organization_id

  before_validation :assign_obisid, :on => :create

  # Return the parent organizations of the service.  Note that this
  # returns the organizations in the reverse order of
  # Organization#parents.
  def parents
    return organization.parents.reverse + [ organization ]
  end

  def core
    return organization if organization.type == 'Core'
  end

  def program
    return core.parent if organization.type == 'Core'
    return organization if organization.type == 'Program'
  end

  def provider
    org = nil
    org = core.program.parent if organization.type == 'Core'
    org = program.parent if organization.type == 'Program'
    org = organization if organization.type == 'Provider'
    org
  end

  def institution
    org = nil
    org = core.program.provider.parent if organization.type == 'Core'
    org = program.provider.parent if organization.type == 'Program'
    org = provider.parent if organization.type == 'Provider'
    org = organization if organization.type == 'Institution'
    org
  end
  
  # Given a dollar amount as a String, return an integer number of
  # cents.
  def self.dollars_to_cents dollars
    # TODO: should this return nil if passed in nil?
    dollars = dollars.gsub(',','')
    (dollars.to_f * 100).to_i
  end

  # Given an integer number of cents, return a Float representing the
  # equivalent amount in dollars.
  def self.cents_to_dollars cents
    return nil unless cents
    cents.to_i / 100.0
  end

  # Checks if the service is currently a one-time-fee
  def is_one_time_fee?
    begin
      self.displayed_pricing_map.is_one_time_fee ? true : false
    rescue
      false
    end
  end

  def display_service_name
    if self.cpt_code and !self.cpt_code.blank?
      service_name = self.name + " (#{self.cpt_code})"
    else
      service_name = self.name
    end
    return service_name
  end

  def display_service_abbreviation
    if self.cpt_code and !self.cpt_code.blank?
      service_abbreviation = self.abbreviation + " (#{self.cpt_code})"
    else
      service_abbreviation = self.abbreviation
    end
    return service_abbreviation
  end

  # Will check for nil display dates on the service's pricing maps
  def verify_display_dates
    is_valid = true
    self.pricing_maps.each do |map|
      unless map.display_date
        is_valid = false
      end
    end

    is_valid
  end

  # Retrieves the correct pricing_map for a service based on the current date and the
  # pricing_map's display date.
  # Returns a pricing_map.
  def displayed_pricing_map date=nil
    unless self.verify_display_dates
      raise TypeError, "One of service's pricing maps has no display date!"
    end
    if pricing_maps && !pricing_maps.empty?
      current_date = date || Time.now.strftime("%F")
      current_maps = pricing_maps.select {|x| x.display_date <= Time.parse(current_date.to_s)}
      if current_maps.empty?
        raise ArgumentError, "Service has no current pricing maps!"
      else
        pricing_map = current_maps.sort {|a,b| b.display_date <=> a.display_date}.first
      end

      return pricing_map
    else
      raise ArgumentError, "Service has no pricing maps!"
    end
  end

  def type
    'service'
  end

  # Find a pricing map with a display date for today's date.
  def current_pricing_map
    return pricing_map_for_date(Date.today)
  end

  # Find a pricing map with a display date corresponding to the given
  # date.
  def pricing_map_for_date(date)
    raise ArgumentError, "Service has no pricing maps" if self.pricing_maps.empty?

    # TODO: use #where? (warning: potential performance issue)
    current_maps = self.pricing_maps.select { |x| x.display_date.to_date <= date.to_date }
    raise ArgumentError, "Service has no current pricing maps" if current_maps.empty?

    sorted_maps = current_maps.sort { |lhs, rhs| lhs.display_date <=> rhs.display_date }
    pricing_map = sorted_maps.last

    return pricing_map
  end

  # Find a pricing map with an effective date for today's date.
  def current_effective_pricing_map
    return effective_pricing_map_for_date(Date.today)
  end

  # Find a pricing map with an effective date corresponding to the given
  # date.
  def effective_pricing_map_for_date(date)
    raise ArgumentError, "Service has no pricing maps" if self.pricing_maps.empty?

    # TODO: use #where? (warning: potential performance issue)
    current_maps = self.pricing_maps.select { |x| x.effective_date.to_date <= date.to_date }
    raise ArgumentError, "Service has no current pricing maps" if current_maps.empty?

    sorted_maps = current_maps.sort { |lhs, rhs| lhs.effective_date <=> rhs.effective_date }
    pricing_map = sorted_maps.last

    return pricing_map
  end
  
  # Find the rate maps for the given display_date and service_rate
  def get_rate_maps(display_date, full_rate)
    hash = PricingMap.rates_from_full(display_date, self.organization_id, full_rate)
    return_map = {
      "federal_rate" => Service.fix_service_rate(hash[:federal_rate]),
      "corporate_rate" => Service.fix_service_rate(hash[:corporate_rate]),
      "other_rate" => Service.fix_service_rate(hash[:other_rate]),
      "member_rate" => Service.fix_service_rate(hash[:member_rate])
    }
    return_map
  end  
  
  # Used to convert and format rates into currency format if rate exists.
  def self.fix_service_rate rate
    if rate.nil?
      return 'N/A'
    else
      return "#{Service.cents_to_dollars(rate)}"
    end
  end

  def can_edit_historical_data_on_new?(user)
    user.can_edit_historical_data_for?(self.organization)
  end

  def increase_decrease_pricing_map(percent_of_change, display_date, effective_date)
    current_map = nil
    begin
      current_map = PricingMap.new(self.effective_pricing_map_for_date(effective_date).attributes)
      current_map.full_rate = current_map.full_rate + (current_map.full_rate * ( (percent_of_change.to_f * 0.01).floor_to(2) ))
    rescue
      current_map = self.pricing_maps.build
      current_map.full_rate = 0
      current_map.unit_factor = 1
      current_map.unit_minimum = 1
      current_map.unit_type = ""
    end
      
    current_map.display_date = display_date
    current_map.effective_date = effective_date
    current_map.save
  end
  
  def has_service_providers?
    self.organization.process_ssrs_parent.service_providers.present? rescue true
  end
end
