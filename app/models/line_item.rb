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

class LineItem < ApplicationRecord

  include RemotelyNotifiable

  audited

  belongs_to :service_request
  belongs_to :service, counter_cache: true
  belongs_to :sub_service_request

  has_many :fulfillments, dependent: :destroy
  has_many :line_items_visits, dependent: :destroy
  has_many :procedures
  has_many :admin_rates, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  has_many :arms, through: :line_items_visits
  has_one :protocol, through: :service_request

  ########################
  ### CWF Associations ###
  ########################

  has_many :fulfillment_line_items, -> { order(:arm_id) }, class_name: 'Shard::Fulfillment::LineItem', foreign_key: :sparc_id

  attr_accessor :pricing_scheme

  accepts_nested_attributes_for :fulfillments, allow_destroy: true

  delegate :one_time_fee, to: :service
  delegate :name, to: :service
  delegate :status, to: :sub_service_request

  validates :service_id, :service_request_id, presence: true
  validates :service_id, uniqueness: { scope: :sub_service_request_id }

  validates :quantity, presence: true, numericality: true, if: Proc.new { |li| li.service.nil? || li.service.one_time_fee? }
  validate :quantity_must_be_smaller_than_max_and_greater_than_min, if: Proc.new { |li| li.quantity && li.service && li.service.one_time_fee? && li.service.current_effective_pricing_map }
  validates :units_per_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: Proc.new { |li| li.service.nil? || li.service.one_time_fee? }

  after_create :build_line_items_visits_if_pppv
  before_destroy :destroy_arms_if_last_pppv_line_item, if: Proc.new { |li| !li.one_time_fee }

  default_scope { order('line_items.id ASC') }

  scope :incomplete, -> {
    joins(:sub_service_request).where.not(sub_service_requests: { status: Status.complete })
  }

  scope :unassigned, -> {
    where(sub_service_request_id: nil)
  }

  def friendly_notable_type
    Service.model_name.human
  end

  ### These only pertain to OTF services
  def otf_unit_type
    service.displayed_pricing_map.try(:otf_unit_type)
  end

  def quantity_type
    service.displayed_pricing_map.try(:quantity_type)
  end
  ### End OTF services only methods (may be more below but these were added)

  def displayed_cost_valid?(displayed_cost)
    return true if displayed_cost.nil?
    is_float  = /\A-?[0-9]+(\.[0-9]*)?\z/ =~ displayed_cost
    num       = displayed_cost.to_f
    errors.add(:displayed_cost, I18n.t(:validation_errors)[:line_items][:displayed_cost_numeric]) if is_float.nil?
    errors.add(:displayed_cost, I18n.t(:validation_errors)[:line_items][:displayed_cost_gte_zero]) if num < 0
    return is_float && num >= 0
  end

  def displayed_cost
    '%.2f' % (applicable_rate / 100.0)
  end

  def displayed_cost=(dollars)
    admin_rates.new( admin_cost: Service.dollars_to_cents(dollars) )
  end

  def pricing_scheme
    @pricing_scheme || 'displayed'
  end

  def in_process_date=(date)
    write_attribute(:in_process_date, Time.strptime(date, "%m/%d/%Y")) if date.present?
  end

  def complete_date=(date)
    write_attribute(:complete_date, Time.strptime(date, "%m/%d/%Y")) if date.present?
  end

  def quantity_must_be_smaller_than_max_and_greater_than_min
    pricing           = self.service.current_effective_pricing_map
    quantity_max      = pricing.units_per_qty_max
    quantity_min      = pricing.quantity_minimum

    if self.quantity < quantity_min
      errors.add(:quantity, :min)
    elsif self.quantity > quantity_max
      errors.add(:quantity, :max)
    end
  end

  def applicable_rate
    rate = nil

    if has_admin_rates?
      rate = self.admin_rates.last.admin_cost
    else
      pricing_map         = self.pricing_scheme == 'displayed' ? self.service.displayed_pricing_map : self.service.current_effective_pricing_map
      pricing_setup       = self.pricing_scheme == 'displayed' ? self.service.organization.current_pricing_setup : self.service.organization.effective_pricing_setup_for_date
      funding_source      = self.service_request.protocol.funding_source_based_on_status
      selected_rate_type  = pricing_setup.rate_type(funding_source)
      applied_percentage  = pricing_setup.applied_percentage(selected_rate_type)

      rate = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
    end

    rate
  end

  def has_admin_rates?
    self.admin_rates.present? && self.admin_rates.last.admin_cost.present?
  end

  def attached_to_submitted_request
    # it's been submitted as long as it's status is past nil, first_draft, or draft
    ![nil, 'first_draft', 'draft'].include?(sub_service_request.status)
  end

  # Returns the cost per unit based on a quantity and the units per quantity if there is one
  def per_unit_cost(quantity_total=self.quantity)
    units_per_quantity = self.units_per_quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      total_quantity = units_per_quantity * quantity_total
      # Need to divide by the unit factor here. Defaulted to 1 if there isn't one
      packages_we_have_to_get = (total_quantity.to_f / self.units_per_package.to_f).ceil
      # The total cost is the number of packages times the rate
      total_cost = packages_we_have_to_get.to_f * self.applicable_rate.to_f
      # And the cost per quantity is the total cost divided by the
      # quantity. The result here may not be a whole number if the
      # quantity is not a multiple of units per package.
      ret_cost = total_cost / quantity_total.to_f

      ret_cost
    end
  end

  # Get the number of units per package as specified in the pricing map.
  # Assumes 1 as the default, if the pricing map does not have a unit
  # factor.
  def units_per_package
    unit_factor = self.service.displayed_pricing_map.unit_factor
    units_per_package = unit_factor || 1

    return units_per_package
  end

  def quantity_total(line_items_visit)
    line_items_visit.sum_visits_research_billing_qty * (line_items_visit.subject_count || 0)
  end

  # Determine the direct costs for a visit-based service for one subject
  def direct_costs_for_visit_based_service_single_subject(line_items_visit)
    # line items visit should also check that it's for the correct protocol
    return 0.0 unless service_request.protocol_id == line_items_visit.arm.protocol_id

    line_items_visit.sum_visits_research_billing_qty * per_unit_cost(quantity_total(line_items_visit))
  end

  # Determine the direct costs for a visit-based service
  def direct_costs_for_visit_based_service
    total = 0
    self.line_items_visits.each do |line_items_visit|
      total += (line_items_visit.subject_count || 0) * self.direct_costs_for_visit_based_service_single_subject(line_items_visit)
    end
    total
  end

  # Determine the direct costs for a one-time-fee service
  def direct_costs_for_one_time_fee
    # TODO: It's a little strange that per_unit_cost divides by
    # quantity, then here we multiply by quantity.  It would arguably be
    # better to calculate total cost here in its own method, then
    # implement per_unit_cost to call that method.
    num = self.quantity || 0.0
    num * self.per_unit_cost
  end

  # Determine the indirect cost rate related to a particular line item
  def indirect_cost_rate
    if Setting.get_value("use_indirect_cost")
      self.service_request.protocol.indirect_cost_rate.to_f / 100
    else
      return 0
    end
  end

  # Determine the indirect cost rate for a visit-based service for one subject
  def indirect_costs_for_visit_based_service_single_subject
    if Setting.get_value("use_indirect_cost")
      total = 0
      self.line_items_visits.each do |line_items_visit|
        total += self.direct_costs_for_visit_based_service_single_subject(line_items_visit) * self.indirect_cost_rate
      end
      return total
    else
      return 0
    end
  end

  # Determine the indirect costs for a visit-based service
  def indirect_costs_for_visit_based_service
    if Setting.get_value("use_indirect_cost")
      self.direct_costs_for_visit_based_service * self.indirect_cost_rate
    else
      return 0
    end
  end

  # Determine the indirect costs for a one-time-fee service
  def indirect_costs_for_one_time_fee
    if self.service.displayed_pricing_map.exclude_from_indirect_cost || !Setting.get_value("use_indirect_cost")
      return 0
    else
      self.direct_costs_for_one_time_fee * self.indirect_cost_rate
    end
  end

  def should_push_to_epic?
    return self.service.send_to_epic
  end

  ### audit reporting methods ###

  def audit_field_value_mapping
    {"service_id" => "Service.find(ORIGINAL_VALUE).name"}
  end

  def audit_excluded_fields
    {'create' => ['service_request_id', 'sub_service_request_id', 'service_id', 'ssr_id', 'deleted_at', 'units_per_quantity']}
  end

  def audit_label audit
    if audit.action == 'create'
      return "#{service.name} added to Service Request #{sub_service_request.display_id}"
    else
      return "#{service.name}"
    end
  end

  ### end audit reporting methods ###

  # Need this for filtering ssr's by user on the cfw home page
  def core
    self.service.organization
  end

  def has_service_relation
    service_relations.any?
  end

  def display_service_abbreviation
    service = self.service

    if service.abbreviation.blank?
      service_abbreviation = service.name
    elsif service.cpt_code and !service.cpt_code.blank?
      service_abbreviation = service.abbreviation + " (#{service.cpt_code})"
    else
      service_abbreviation = service.abbreviation
    end

    unless self.sub_service_request.ssr_id.nil?
      service_abbreviation = "(#{self.sub_service_request.ssr_id}) " + service_abbreviation
    end

    service_abbreviation
  end

  private

  def build_line_items_visits_if_pppv
    if self.service && !self.one_time_fee && self.service_request.try(:arms).try(:any?)
      self.service_request.arms.each do |arm|
        arm.line_items_visits.create(line_item: self, subject_count: arm.subject_count)
      end
    end
  end

  def destroy_arms_if_last_pppv_line_item
    if self.try(:protocol).try(:service_requests).try(:none?) { |sr| sr.has_per_patient_per_visit_services? }
      self.service_request.protocol.try(:arms).try(:destroy_all)
    end
  end
end
