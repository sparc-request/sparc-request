class VisitGrouping < ActiveRecord::Base
  belongs_to :arm
  belongs_to :line_item

  has_many :visits, :dependent => :destroy, :order => 'position'

  attr_accessible :arm_id
  attr_accessible :line_item_id
  attr_accessible :subject_count

  # Returns the cost per unit based on a quantity (usually just the quantity on the line_item)
  def per_unit_cost quantity_total=self.quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      units_per_package = self.units_per_package
      packages_we_have_to_get = (quantity_total.to_f / units_per_package.to_f).ceil
      total_cost = packages_we_have_to_get.to_f * self.line_item.applicable_rate.to_f
      ret_cost = total_cost / quantity_total.to_f
      unless self.units_per_quantity.blank?
        ret_cost = ret_cost * self.units_per_quantity
      end
      return ret_cost
    end
  end

  def units_per_package
    unit_factor = 1 # TODO: Fix this for arms self.line_item.service.displayed_pricing_map.unit_factor
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
end

