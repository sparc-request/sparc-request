# Copyright © 2011 MUSC Foundation for Research Development
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

class LineItem < ActiveRecord::Base
  audited

  belongs_to :service_request
  belongs_to :service, :include => [:pricing_maps, :organization]
  belongs_to :sub_service_request
  has_many :fulfillments, :dependent => :destroy

  has_many :line_items_visits, :dependent => :destroy
  has_many :arms, :through => :line_items_visits
  has_many :procedures
  has_many :admin_rates, :dependent => :destroy

  attr_accessible :service_request_id
  attr_accessible :sub_service_request_id
  attr_accessible :service_id
  attr_accessible :optional
  attr_accessible :complete_date
  attr_accessible :in_process_date
  attr_accessible :units_per_quantity
  attr_accessible :quantity
  attr_accessible :fulfillments_attributes
  attr_accessible :displayed_cost
 
  attr_accessor :pricing_scheme

  accepts_nested_attributes_for :fulfillments, :allow_destroy => true

  def displayed_cost
    applicable_rate
  end

  def displayed_cost=(dollars)
    admin_rates.new :admin_cost => dollars.blank? ? nil : Service.dollars_to_cents(dollars)
  end

  def pricing_scheme
    @pricing_scheme || 'displayed'
  end

  validates :service_id, :numericality => true
  validates :service_request_id, :numericality => true

  after_destroy :remove_procedures

  # TODO: order by date/id instead of just by date?
  default_scope :order => 'line_items.id ASC'

  def applicable_rate(appointment_completed_date=nil)
    rate = nil
    if appointment_completed_date
      if has_admin_rates? appointment_completed_date
        rate = admin_rate_for_date(appointment_completed_date)
      else
        pricing_map         = self.pricing_scheme == 'displayed' ? self.service.displayed_pricing_map : self.service.effective_pricing_map_for_date(appointment_completed_date)
        pricing_setup       = self.pricing_scheme == 'displayed' ? self.service.organization.current_pricing_setup : self.service.organization.effective_pricing_setup_for_date(appointment_completed_date)
        funding_source      = self.service_request.protocol.funding_source_based_on_status
        selected_rate_type  = pricing_setup.rate_type(funding_source)
        applied_percentage  = pricing_setup.applied_percentage(selected_rate_type)
      
        rate = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
      end
    else 
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
    end

    rate
  end
  
  def has_admin_rates? appointment_completed_date=nil
    has_admin_rates = !self.admin_rates.empty? && !self.admin_rates.last.admin_cost.blank?
    has_admin_rates = has_admin_rates && self.admin_rates.select{|ar| ar.created_at.to_date <= appointment_completed_date}.size > 0 if appointment_completed_date
    has_admin_rates
  end

  def admin_rate_for_date appointment_completed_date
    sorted_rates = self.admin_rates.order(:id).reverse
    sorted_rates.each do |rate|
      if rate.created_at.to_date <= appointment_completed_date
        return rate.admin_cost
      end
    end
  end

  def attached_to_submitted_request
    # it's been submitted as long as it's status is past nil, first_draft, or draft
    ![nil, 'first_draft', 'draft'].include?(sub_service_request.status)
  end

  # Returns the cost per unit based on a quantity and the units per quantity if there is one
  def per_unit_cost(quantity_total=self.quantity, appointment_completed_date=nil)
    units_per_quantity = self.units_per_quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      total_quantity = units_per_quantity * quantity_total
      # Need to divide by the unit factor here. Defaulted to 1 if there isn't one
      packages_we_have_to_get = (total_quantity.to_f / self.units_per_package.to_f).ceil
      # The total cost is the number of packages times the rate
      total_cost = packages_we_have_to_get.to_f * self.applicable_rate(appointment_completed_date).to_f
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
    # quantity_total = self.visits.map {|x| x.research_billing_qty}.inject(:+) * self.subject_count
    quantity_total = line_items_visit.visits.sum('research_billing_qty')
    return quantity_total * line_items_visit.subject_count
  end

  # Returns a hash of subtotals for the visits in the line item.
  # Visit totals depend on the quantities in the other visits, so it would be clunky
  # to compute one visit at a time
  def per_subject_subtotals(visits=self.visits)
    totals = { }
    quantity_total = quantity_total()
    per_unit_cost = per_unit_cost(quantity_total)

    visits.each do |visit|
      totals[visit.id.to_s] = visit.cost(per_unit_cost)
    end

    return totals
  end

  # Determine the direct costs for a visit-based service for one subject
  def direct_costs_for_visit_based_service_single_subject(line_items_visit)
    # line items visit should also check that it's for the correct protocol
    return 0.0 unless service_request.protocol_id == line_items_visit.arm.protocol_id
    
    research_billing_qty_total = line_items_visit.visits.sum(&:research_billing_qty)
    
    subject_total = research_billing_qty_total * per_unit_cost(quantity_total(line_items_visit))
    subject_total
  end

  # Determine the direct costs for a visit-based service
  def direct_costs_for_visit_based_service
    total = 0
    self.line_items_visits.each do |line_items_visit|
      total += line_items_visit.subject_count * self.direct_costs_for_visit_based_service_single_subject(line_items_visit)
    end
    total
  end

  # Determine the direct costs for a one-time-fee service
  def direct_costs_for_one_time_fee
    num = self.quantity || 0.0
    num * self.per_unit_cost
  end

  # This determines the complete cost for a line item with fulfillments
  # taking into account the possibility for a unit factor greater than 1
  # Only fulfillments within date range will be calculated
  def direct_cost_for_one_time_fee_with_fulfillments start_date, end_date
    total = 0.0
    if !self.fulfillments.empty?
      self.fulfillments.each do |fulfillment|
        if fulfillment.within_date_range?(start_date, end_date)
          if fulfillment.unit_quantity?
            total += fulfillment.quantity * fulfillment.unit_quantity
          else
            total += fulfillment.quantity
          end
        end
      end
      total = ((total / units_per_package).ceil * self.applicable_rate)
    end

    total
  end

  # Determine the indirect cost rate related to a particular line item
  def indirect_cost_rate
    if USE_INDIRECT_COST
      self.service_request.protocol.indirect_cost_rate.to_f / 100
    else
      return 0
    end
  end

  # Determine the indirect cost rate for a visit-based service for one subject
  def indirect_costs_for_visit_based_service_single_subject
    if USE_INDIRECT_COST
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
    if USE_INDIRECT_COST
      self.direct_costs_for_visit_based_service * self.indirect_cost_rate
    else
      return 0
    end
  end

  # Determine the indirect costs for a one-time-fee service
  def indirect_costs_for_one_time_fee
    if self.service.displayed_pricing_map.exclude_from_indirect_cost || !USE_INDIRECT_COST
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

  # Don't like duplicate code but this will make it easier to
  # to check for service relations when doing mass visit assignment
  # like ServiceRequest#select_calendar_row
  def has_service_relation
    # Get the relations for this line item and others to this line item
    service_relations = ServiceRelation.find_all_by_service_id(self.service_id)
    related_service_relations = ServiceRelation.find_all_by_related_service_id(self.service_id)

    # Narrow the list to those with linked quantities
    service_relations = service_relations.reject { |sr| sr.linked_quantity == false }
    related_service_relations = related_service_relations.reject { |sr| sr.linked_quantity == false }

    # Check to see if this line item even has a relation
    return (service_relations.empty? && related_service_relations.empty?) ? false : true
  end

  def check_service_relations line_items, pppv_services=false, visit=nil
    # Get the relations for this line item and others to this line item
    service_relations = ServiceRelation.find_all_by_service_id(self.service_id)
    related_service_relations = ServiceRelation.find_all_by_related_service_id(self.service_id)

    # Narrow the list to those with linked quantities
    service_relations = service_relations.reject { |sr| sr.linked_quantity == false }
    related_service_relations = related_service_relations.reject { |sr| sr.linked_quantity == false }

    # Check to see if this line item even has a relation
    return true if service_relations.empty? && related_service_relations.empty?

    # Check to see that the quanties are less than the max together
    if pppv_services
      return false if check_service_relation_pppv(service_relations, line_items, visit) == false
      return false if check_service_relation_pppv(related_service_relations, line_items, visit, true) == false
    else
      return false if check_service_relation_otf(service_relations, line_items) == false
      return false if check_service_relation_otf(related_service_relations, line_items, true) == false
    end

    # No problems with quantity totals
    return true

  end

  private

  def check_service_relation_otf service_relations, line_items, related=false
    service_relations.each do |sr|
      # Check to see if the request has the service in the relation
      sr_id = related ? sr.service_id : sr.related_service_id
      line_item = line_items.detect { |li| li.service_id == sr_id }
      next unless line_item

      if self.quantity + line_item.quantity > sr.linked_quantity_total
        self.errors.add(:invalid_total, "The quantity between #{self.service.name} and #{line_item.service.name} is greater than the total quantity amount allowed which is #{sr.linked_quantity_total}")
        return false
      end
    end

    return true
  end

  def check_service_relation_pppv service_relations, line_items, visit, related=false
    arm_id = visit.visit_group.arm.id
    visit_position = visit.position - 1

    service_relations.each do |sr|
      # Check to see if the request has the service in the relation
      sr_id = related ? sr.service_id : sr.related_service_id
      line_item = line_items.detect { |li| li.service_id == sr_id }
      next unless line_item && line_item.arms.find(arm_id)

      line_item_visit = line_item.line_items_visits.find_by_arm_id arm_id
      v = line_item_visit.visits[visit_position]

      if visit.quantity_total + v.quantity_total > sr.linked_quantity_total
        self.errors.add(:invalid_total, "The quantity between #{self.service.name} and #{line_item.service.name} is greater than the total quantity amount allowed which is #{sr.linked_quantity_total}")
        return false
      end
    end

    return true
  end

  def remove_procedures
    procedures = self.procedures
    procedures.each do |pro|
      if pro.completed?
        pro.update_attributes(service_id: self.service_id, line_item_id: nil, visit_id: nil)
      else
        pro.destroy
      end
    end
  end
end
