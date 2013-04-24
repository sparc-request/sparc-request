class LineItemsVisit < ActiveRecord::Base
  belongs_to :arm
  belongs_to :line_item

  has_many :visits, :dependent => :destroy, :include => :visit_group, :order => 'visit_groups.position'

  attr_accessible :arm_id
  attr_accessible :line_item_id
  attr_accessible :subject_count  # number of subjects for this visit grouping

  # def create_or_destroy_visits(visit_count = self.arm.visit_count || 0)
  #   if visit_count == self.visits.count
  #     # if we already have the right number of visits, then do nothing
  #     return
  #   end

  #   ActiveRecord::Base.transaction do
  #     if visit_count > self.visits.count
  #       # if we don't have enough visits, then create them
  #       difference = visit_count - self.visits.count
  #       Visit.bulk_create(difference, :line_items_visit_id => self.id)

  #     elsif arm.visit_count < self.visits.count
  #       # if we have too many visits, then delete some
  #       self.visits.last(self.visits.count - visit_count).each do |visit|
  #         visit.delete
  #       end
  #     end
  #   end
  # end

  def create_visits
    # Visit.bulk_create(self.arm.visit_count, :line_items_visit_id => self.id)
    ActiveRecord::Base.transaction do
      self.arm.visit_groups.each do |vg|
        self.add_visit(vg)
      end
    end
  end

  def update_visit_names line_items_visit
    self.visits.count do |index|
      self.visits[index].visit_group.name = line_items_visit.visits[index].visit_group.name
    end
  end

  # Returns the cost per unit based on a quantity (usually just the quantity on the line_item)
  def per_unit_cost quantity_total=self.line_item.quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      units_per_package = self.units_per_package
      packages_we_have_to_get = (quantity_total.to_f / units_per_package.to_f).ceil
      total_cost = packages_we_have_to_get.to_f * self.line_item.applicable_rate.to_f
      ret_cost = total_cost / quantity_total.to_f
      unless self.line_item.units_per_quantity.blank?
        ret_cost = ret_cost * self.line_item.units_per_quantity
      end
      return ret_cost
    end
  end

  def units_per_package
    unit_factor = self.line_item.service.displayed_pricing_map.unit_factor
    units_per_package = unit_factor || 1
    return units_per_package
  end

  def quantity_total
    # quantity_total = self.visits.map {|x| x.research_billing_qty}.inject(:+) * self.subject_count
    quantity_total = self.visits.sum('research_billing_qty')
    return quantity_total * self.subject_count
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
  def direct_costs_for_visit_based_service_single_subject
    # TODO: use sum() here
    # totals_array = self.per_subject_subtotals(visits).values.select {|x| x.class == Float}
    # subject_total = totals_array.empty? ? 0 : totals_array.inject(:+)
    result = self.connection.execute("SELECT SUM(research_billing_qty) FROM visits WHERE line_items_visit_id=#{self.id} AND research_billing_qty >= 1")
    research_billing_qty_total = result.to_a[0][0] || 0
    subject_total = research_billing_qty_total * per_unit_cost(quantity_total())

    subject_total
  end

  # Determine the direct costs for a visit-based service
  def direct_costs_for_visit_based_service
    self.subject_count * self.direct_costs_for_visit_based_service_single_subject
  end

  # Determine the direct costs for a one-time-fee service
  def direct_costs_for_one_time_fee
    num = self.line_item.quantity || 0.0
    num * self.per_unit_cost
  end

  # Determine the indirect cost rate related to a particular line item
  def indirect_cost_rate
    if USE_INDIRECT_COST
      self.line_item.service_request.protocol.indirect_cost_rate.to_f / 100
    else
      return 0
    end
  end

  # Determine the indirect cost rate for a visit-based service for one subject
  def indirect_costs_for_visit_based_service_single_subject
    if USE_INDIRECT_COST
      self.direct_costs_for_visit_based_service_single_subject * self.indirect_cost_rate
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
    if self.line_item.service.displayed_pricing_map.exclude_from_indirect_cost || !USE_INDIRECT_COST
      return 0
    else
      self.direct_costs_for_one_time_fee * self.indirect_cost_rate
    end
  end

  # Add a new visit.  Returns the new Visit upon success or false upon
  # error.
  def add_visit visit_group
    self.visits.create(visit_group_id: visit_group.id)
  end

  def remove_visit visit_group
    visit = self.visits.find_by_visit_group_id(visit_group.id)
    visit.delete
  end
end
