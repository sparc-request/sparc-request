class Arm < ActiveRecord::Base
  belongs_to :service_request

  has_many :visit_groupings, :dependent => :destroy
  has_many :line_items, :through => :visit_groupings

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count

  def per_patient_per_visit_line_items
    visit_groupings.each.map do |vg|
      vg.line_item
    end.compact
  end

  def maximum_direct_costs_per_patient visit_groupings=self.visit_groupings
    total = 0.0
    visit_groupings.each do |vg|
      total += vg.direct_costs_for_visit_based_service_single_subject
    end

    total
  end

  def maximum_indirect_costs_per_patient visit_groupings=self.visit_groupings
    if USE_INDIRECT_COST
      self.maximum_direct_costs_per_patient(visit_groupings) * (self.service_request.protocol.indirect_cost_rate.to_f / 100)
    else
      return 0
    end
  end

  def maximum_total_per_patient visit_groupings=self.visit_groupings
    self.maximum_direct_costs_per_patient(visit_groupings) + maximum_indirect_costs_per_patient(visit_groupings)
  end

  def direct_costs_for_visit_based_service
    total = 0.0
    visit_groupings.each do |vg|
      total += vg.direct_costs_for_visit_based_service
    end
    return total
  end

  def indirect_costs_for_visit_based_service
    total = 0.0
    visit_groupings.each do |vg|
      total += vg.indirect_costs_for_visit_based_service
    end
    return total
  end

  def total_costs_for_visit_based_service
    direct_costs_for_visit_based_service + indirect_costs_for_visit_based_service
  end
end
