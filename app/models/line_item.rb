class LineItem < ActiveRecord::Base
  audited

  belongs_to :service_request
  belongs_to :service, :include => [:pricing_maps, :organization]
  belongs_to :sub_service_request
  has_many :fulfillments, :dependent => :destroy

  has_many :line_items_visits, :dependent => :destroy
  has_many :arms, :through => :line_items_visits
  has_many :procedures

  attr_accessible :service_request_id
  attr_accessible :sub_service_request_id
  attr_accessible :service_id
  attr_accessible :optional
  attr_accessible :quantity
  attr_accessible :complete_date
  attr_accessible :in_process_date
  attr_accessible :units_per_quantity

  validates :service_id, :numericality => true
  validates :service_request_id, :numericality => true

  after_destroy :remove_procedures

  # TODO: order by date/id instead of just by date?
  default_scope :order => 'line_items.id ASC'

  def applicable_rate
    pricing_map         = self.service.displayed_pricing_map
    pricing_setup       = self.service.organization.current_pricing_setup
    funding_source      = self.service_request.protocol.funding_source_based_on_status
    selected_rate_type  = pricing_setup.rate_type(funding_source)
    applied_percentage  = pricing_setup.applied_percentage(selected_rate_type)
    rate                = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
    return rate
  end

  # Returns the cost per unit based on a quantity (usually just the quantity on the line_item)
  def per_unit_cost quantity_total=self.quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      # Calculate the total number of packages that must be purchased.
      # If the quantity requested is not an even multiple of the number
      # of units per package, then we have to round up, so that a whole
      # number of packages is being purchased.
      packages_we_have_to_get = (quantity_total.to_f / self.units_per_package.to_f).ceil

      # The total cost is the number of packages times the rate
      total_cost = packages_we_have_to_get.to_f * self.applicable_rate.to_f

      # And the cost per quantity is the total cost divided by the
      # quantity.  The result here may not be a whole number if the
      # quantity is not a multiple of units per package.
      ret_cost = total_cost / quantity_total.to_f

      # Cost per unit is equal to cost per quantity times units per
      # quantity.
      unless self.units_per_quantity.blank?
        ret_cost = ret_cost * self.units_per_quantity
      end

      return ret_cost
    end
  end

  # Get the number of units per package as specified in the pricing map.
  # Assumes 1 as the default, if the pricing map does not have a unit
  # factor.  If the pricing map is a one time fee, the units per package
  # are one.
  def units_per_package
    unless self.service.displayed_pricing_map.is_one_time_fee
      unit_factor = self.service.displayed_pricing_map.unit_factor
      units_per_package = unit_factor || 1
    else
      units_per_package = 1
    end

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
    # TODO: It's a little strange that per_unit_cost divides by
    # quantity, then here we multiply by quantity.  It would arguably be
    # better to calculate total cost here in its own method, then
    # implement per_unit_cost to call that method.
    num = self.quantity || 0.0
    num * self.per_unit_cost
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

  def check_service_relations line_items
    # Get the relations for this line item and others to this line item
    service_relations = ServiceRelation.find_all_by_service_id(self.service_id)
    related_service_relations = ServiceRelation.find_all_by_related_service_id(self.service_id)

    # Narrow the list to those with linked quantities
    service_relations = service_relations.reject { |sr| sr.linked_quantity == false }
    related_service_relations = related_service_relations.reject { |sr| sr.linked_quantity == false }

    # Check to see if this line item even has a relation
    return true if service_relations.empty? && related_service_relations.empty?

    # Check to see that the quanties are less than the max together
    service_relations.each do |sr|
      # Check to see if the request has the service in the relation
      line_item = line_items.detect { |li| li.service_id == sr.related_service_id }
      next unless line_item

      if self.quantity + line_item.quantity > sr.linked_quantity_total
        errors.add(:invalid_total, "The quantity between #{self.service.name} and #{line_item.service.name} is greater than linked quantity total which is #{sr.linked_quantity_total}")
        return false
      end
    end

    # Check to see that the quanties are less than the max together
    related_service_relations.each do |sr|
      # Check to see if the request has the service in the relation
      line_item = line_items.detect { |li| li.service_id == sr.service_id }
      next unless line_item

      if self.quantity + line_item.quantity > sr.linked_quantity_total
        errors.add(:invalid_total, "The quantity between #{self.service.name} and #{line_item.service.name} is greater than linked quantity total which is #{sr.linked_quantity_total}")
        return false
      end
    end

    return true

  end

  private

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
