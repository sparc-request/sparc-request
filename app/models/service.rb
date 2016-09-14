# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Service < ActiveRecord::Base

  include RemotelyNotifiable

  audited
  acts_as_taggable

  RATE_TYPES = [{:display => "Service Rate", :value => "full"}, {:display => "Federal Rate", :value => "federal"},
                {:display => "Corporate Rate", :value => "corporate"}, {:display => "Other Rate", :value => "other"},
                {:display => "Member Rate", :value => "member"}]

  belongs_to :organization, -> { includes(:pricing_setups) }
  belongs_to :revenue_code_range
  # set ":inverse_of => :service" so that the first pricing map can be validated before the service has been saved
  has_many :pricing_maps, :inverse_of => :service, :dependent => :destroy
  has_many :service_providers, :dependent => :destroy
  has_many :sub_service_requests, through: :line_items
  has_many :service_requests, through: :sub_service_requests
  has_many :line_items, :dependent => :destroy
  has_many :identities, :through => :service_providers
  has_many :questionnaires
  has_many :submissions

  # Services that this service depends on
  # TODO: Andrew thinks "related services" is a bad name
  has_many :service_relations, :dependent => :destroy
  has_many :related_services, :through => :service_relations
  has_many :required_services, -> { where("optional = ? and is_available = ?", false, true) }, :through => :service_relations, :source => :related_service
  has_many :optional_services, -> { where("optional = ? and is_available = ?", true, true) }, :through => :service_relations, :source => :related_service

  # Services that depend on this service
  has_many :depending_service_relations, :class_name => 'ServiceRelation', :foreign_key => 'related_service_id'
  has_many :depending_services, :through => :depending_service_relations, :source => :service

  # Surveys associated with this service
  has_many :associated_surveys, :as => :surveyable

  attr_accessible :name
  attr_accessible :abbreviation
  attr_accessible :order
  attr_accessible :description
  attr_accessible :is_available
  attr_accessible :service_center_cost
  attr_accessible :cpt_code
  attr_accessible :eap_id
  attr_accessible :charge_code
  attr_accessible :revenue_code
  attr_accessible :organization_id
  attr_accessible :send_to_epic
  attr_accessible :tag_list
  attr_accessible :revenue_code_range_id
  attr_accessible :line_items_count
  attr_accessible :one_time_fee
  attr_accessible :components

  validate :validate_pricing_maps_present

  ###############################################
  # Validations
  def validate_pricing_maps_present
    errors.add(:service, "must contain at least 1 pricing map.") if pricing_maps.length < 1
  end
  ###############################################

  def process_ssrs_organization
    organization.process_ssrs_parent
  end

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

  # do i have any available surveys, otherwise, look up tree and return first available surveys
  def available_surveys
    available = nil

    parents.each do |parent|
      next if parent.type == 'Institution' # Institutions can't define associated surveys
      available = parent.associated_surveys.map(&:survey) unless parent.associated_surveys.empty?
    end

    available = associated_surveys.map(&:survey) unless associated_surveys.empty? # i have available surveys, use those instead

    available
  end

  # Given a dollar amount as a String, return an integer number of
  # cents.
  def self.dollars_to_cents dollars
    # TODO: should this return nil if passed in nil?
    dollars = dollars.gsub(',','')
    (BigDecimal(dollars) * 100).to_i
  end

  # Given an integer number of cents, return a Float representing the
  # equivalent amount in dollars.
  def self.cents_to_dollars cents
    return nil unless cents
    cents.to_i / 100.0
  end

  # Display pricing formatting for reporting
  def report_pricing currency
    '$' + sprintf("%.2f", currency.to_f / 100.0)
  end

  def display_service_name(charge_code = false)
    service_name = self.name

    if self.cpt_code and !self.cpt_code.blank?
      service_name += " (#{self.cpt_code})"
    end

    if charge_code
      if self.charge_code and !self.charge_code.blank?
        service_name += " (#{self.charge_code})"
      end
    end

    return service_name
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
      current_date = (date || Date.today).to_date
      current_maps = pricing_maps.select {|x| x.display_date <= current_date}
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

  # Find a pricing map with a display date for today's date.
  def current_pricing_map
    return pricing_map_for_date(Date.today)
  end

  #This method is only used for the service pricing report
  def pricing_map_for_date(date)
    unless pricing_maps.empty?
      current_maps = self.pricing_maps.select { |x| x.display_date.to_date <= date.to_date }
      if current_maps.empty?
        return false
      end

      sorted_maps = current_maps.sort { |lhs, rhs| lhs.display_date <=> rhs.display_date }
      pricing_map = sorted_maps.last

      return pricing_map
    else
      return false
    end
  end

  # Find a pricing map with an effective date for today's date.
  def current_effective_pricing_map
    return effective_pricing_map_for_date(Date.today)
  end

  # Find a pricing map with an effective date corresponding to the given
  # date.
  def effective_pricing_map_for_date(date=Date.today)
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
      rate = sprintf( '%0.2f', Service.cents_to_dollars(rate).to_f.round(2) )
      return "#{rate}"
    end
  end

  def can_edit_historical_data_on_new?(user)
    user.can_edit_historical_data_for?(self.organization)
  end

  def increase_decrease_pricing_map(percent_of_change, display_date, effective_date)
    current_map = nil
    begin
      effective_pricing_map = self.effective_pricing_map_for_date(effective_date).attributes

      ## Deleting the attributes to prevent mass-assignment errors.
      effective_pricing_map.delete('id')
      effective_pricing_map.delete('created_at')
      effective_pricing_map.delete('updated_at')
      effective_pricing_map.delete('deleted_at')

      current_map = PricingMap.new(effective_pricing_map)
      current_map.full_rate = current_map.full_rate + (current_map.full_rate * ( (percent_of_change.to_f * 0.01).floor_to(2) ))
    rescue
      current_map = self.pricing_maps.build
      current_map.full_rate = 0
      current_map.unit_factor = 1
      current_map.unit_minimum = 1
      current_map.unit_type = "Each"
    end

    current_map.display_date = display_date
    current_map.effective_date = effective_date
    current_map.save
  end

  def has_service_providers?
    organization.process_ssrs_parent.service_providers.present? rescue true
  end

  def is_ctrc_clinical_service?
    if organization.present?
      organization.tag_list.include? 'ctrc_clinical_services'
    else
      false
    end
  end

  def is_ctrc?
    organization.has_tag? 'ctrc'
  end

  def parents_available?
    self.parents.map(&:is_available).compact.all?
  end

  def notify_remote_around_update?
    true
  end

  def remotely_notifiable_attributes_to_watch_for_change
    ["components"]
  end
end
