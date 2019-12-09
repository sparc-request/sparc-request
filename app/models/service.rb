# Copyright © 2011-2019 MUSC Foundation for Research Development
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

class Service < ApplicationRecord

  include RemotelyNotifiable
  include ServiceUtility

  audited
  acts_as_taggable

  RATE_TYPES = {
    full: "Service Rate", federal: "Federal Rate", corporate: "Corporate Rate",
    member: "Member Rate", other: "Other Rate"
  }

  belongs_to :organization, -> { includes(:pricing_setups) }
  belongs_to :revenue_code_range

  # set ":inverse_of => :service" so that the first pricing map can be validated before the service has been saved
  has_many :pricing_maps, :inverse_of => :service, :dependent => :destroy
  has_many :line_items, :dependent => :destroy
  has_many :forms, -> { active }, as: :surveyable, dependent: :destroy# Surveys associated with this service
  has_many :service_relations, :dependent => :destroy
  has_many :depending_service_relations, :class_name => 'ServiceRelation', :foreign_key => 'related_service_id'# Services that depend on this service
  has_many :associated_surveys, as: :associable, dependent: :destroy

  has_many :sub_service_requests, through: :line_items
  has_many :service_requests, through: :sub_service_requests

  # Services that this service depends on
  has_many :related_services, :through => :service_relations
  has_many :required_services, -> { where("required = ? and is_available = ?", true, true) }, :through => :service_relations, :source => :related_service
  has_many :optional_services, -> { where("required = ? and is_available = ?", false, true) }, :through => :service_relations, :source => :related_service
  has_many :surveys, through: :associated_surveys

  has_many :depending_services, :through => :depending_service_relations, :source => :service# Services that depend on this service

  ## commented out to remove tags, but will likely be added in later ##
  # has_many :taggings, through: :organization
  # has_many :tags, through: :taggings

  validates :abbreviation,
            :order,
            presence: true, on: :update
  validates :name, presence: true
  validate  :one_time_fee_choice
  validates :order, numericality: { only_integer: true }, on: :update

  default_scope -> {
    order(:order, :name)
  }

  scope :available, -> {
    where(is_available: true)
  }

  scope :one_time_fee, -> {
    where(one_time_fee: true)
  }

  scope :per_patient_per_visit, -> {
    where(one_time_fee: false)
  }

  # Services listed under the funding organizations
  scope :funding_opportunities, -> { where(organization_id: Setting.get_value("funding_org_ids")) }

  def humanized_status
    self.is_available ? I18n.t(:reporting)[:service_pricing][:available] : I18n.t(:reporting)[:service_pricing][:unavailable]
  end

  def process_ssrs_organization
    organization.process_ssrs_parent || organization
  end

  # Return the parent organizations of the service.
  def parents id_only=false
    parent_org = id_only ? organization.id : organization
    return [ parent_org ] + organization.parents(id_only)
  end

  # Service belongs to Organization A, which belongs to
  # Organization B, which belongs to Organization C, return "C > B > A".
  # This "hierarchy" stops at a process_ssrs Organization.
  def organization_hierarchy(include_self=false, process_ssrs=true, use_css=false, use_array=false)
    parent_orgs = self.parents.reverse

    if process_ssrs
      root = parent_orgs.find_index { |org| org.process_ssrs? } || (parent_orgs.length - 1)
    else
      root = parent_orgs.length - 1
    end

    if use_array
      parent_orgs[0..root]
    elsif use_css
      parent_orgs[0..root].map{ |o| "<span class='#{o.css_class}-text'>#{o.abbreviation}</span>"}.join('<span> / </span>') + (include_self ? '<span> / </span>' + "<span>#{self.abbreviation}</span>" : '')
    else
      parent_orgs[0..root].map(&:abbreviation).join(' > ') + (include_self ? ' > ' + self.abbreviation : '')
    end
  end

  def core
    return organization if organization.type == 'Core'
  end

  def program
    return core.parent  if organization.type == 'Core'
    return organization if organization.type == 'Program'
  end

  def provider
    return program.parent if ['Core', 'Program'].include?(organization.type)
    return organization   if organization.type == 'Provider'
  end

  def institution
    return provider.parent  if ['Core', 'Program', 'Provider'].include?(organization.type)
    return organization     if organization.type == 'Institution'
  end

  # do i have any available surveys, otherwise, look up tree and return first available surveys
  def available_surveys
    (self.surveys + self.parents.map{ |parent| parent.surveys }.flatten).compact.uniq
  end

  # Given a dollar amount as a String, return an integer number of
  # cents.
  def self.dollars_to_cents dollars
    dollars = dollars.gsub(',','')
    #check if dollars arg will be a valid for BigDecimal conversion
    if ServiceUtility.valid_float?(dollars)
      #if not we convert dollars to an integer
      (BigDecimal(dollars) * 100).to_i
    else
      (BigDecimal(dollars.to_i) * 100).to_i
    end
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

    service_name = service_name.gsub("/", "/ ")

    service_name
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
        # If two pricing maps have the same display_date, prefer the most
        # recently created pricing_map.
        pricing_map = current_maps.sort {|a,b| [b.display_date, b.id] <=> [a.display_date, a.id]}.first
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
    self.pricing_maps.where(PricingMap.arel_table[:effective_date].lteq(date.to_date)).order(:effective_date).last
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
    process_ssrs_org = organization.process_ssrs_parent || organization
    process_ssrs_org.service_providers.present? rescue true
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

  def direct_link
    "#{Setting.get_value('root_url')}/services/#{id}"
  end

  private

  def one_time_fee_choice
    if one_time_fee.nil?
      errors[:base] << "You must choose either One Time Fee, or Clinical Service."
    end
  end

end
