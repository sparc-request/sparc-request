class LineItem < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_request
  belongs_to :service, :include => [:pricing_maps, :organization]
  belongs_to :sub_service_request
  has_many :fulfillments, :dependent => :destroy

  has_many :visit_groupings, :dependent => :destroy
  has_many :arms, :through => :visit_groupings

  attr_accessible :service_request_id
  attr_accessible :sub_service_request_id
  attr_accessible :ssr_id
  attr_accessible :service_id
  attr_accessible :optional
  attr_accessible :quantity
  attr_accessible :complete_date
  attr_accessible :in_process_date
  attr_accessible :units_per_quantity

  validates :service_id, :numericality => true
  validates :service_request_id, :numericality => true

  # TODO: order by date/id instead of just by date?
  default_scope :order => 'id ASC'

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
      units_per_package = self.units_per_package
      packages_we_have_to_get = (quantity_total.to_f / units_per_package.to_f).ceil
      total_cost = packages_we_have_to_get.to_f * self.applicable_rate.to_f
      ret_cost = total_cost / quantity_total.to_f
      unless self.units_per_quantity.blank?
        ret_cost = ret_cost * self.units_per_quantity
      end
      return ret_cost
    end
  end

  def units_per_package
    unit_factor = self.service.displayed_pricing_map.unit_factor
    units_per_package = unit_factor || 1
    return units_per_package
  end

  def quantity_total(visit_grouping)
    # quantity_total = self.visits.map {|x| x.research_billing_qty}.inject(:+) * self.subject_count
    quantity_total = visit_grouping.visits.sum('research_billing_qty')
    return quantity_total * visit_grouping.subject_count
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
  def direct_costs_for_visit_based_service_single_subject(visit_grouping)
    # TODO: use sum() here
    # totals_array = self.per_subject_subtotals(visits).values.select {|x| x.class == Float}
    # subject_total = totals_array.empty? ? 0 : totals_array.inject(:+)
    result = visit_grouping.connection.execute("SELECT SUM(research_billing_qty) FROM visits WHERE visit_grouping_id=#{visit_grouping.id} AND research_billing_qty >= 1")
    research_billing_qty_total = result.to_a[0][0] || 0
    subject_total = research_billing_qty_total * per_unit_cost(quantity_total(visit_grouping))

    subject_total
  end

  # Determine the direct costs for a visit-based service
  def direct_costs_for_visit_based_service
    total = 0
    self.visit_groupings.each do |visit_grouping|
      total += visit_grouping.subject_count * self.direct_costs_for_visit_based_service_single_subject(visit_grouping)
    end
    total
  end

  # Determine the direct costs for a one-time-fee service
  def direct_costs_for_one_time_fee
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
      self.visit_groupings.each do |visit_grouping|
        total += self.direct_costs_for_visit_based_service_single_subject(visit_grouping) * self.indirect_cost_rate
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
end

