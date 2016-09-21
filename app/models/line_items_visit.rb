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

class LineItemsVisit < ActiveRecord::Base

  include RemotelyNotifiable

  audited

  belongs_to :arm
  belongs_to :line_item
  has_one :service_request, through: :line_item
  has_one :sub_service_request, through: :line_item
  has_one :service, through: :line_item
  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, :dependent => :destroy

  attr_accessible :arm_id
  attr_accessible :line_item_id
  attr_accessible :subject_count  # number of subjects for this visit grouping
  attr_accessible :hidden

  after_save :set_arm_edited_flag_on_subjects

  def set_arm_edited_flag_on_subjects
    self.arm.set_arm_edited_flag_on_subjects
  end

  # Find a LineItemsVisit for the given arm and line item.  If it does
  # not exist, create it first, then return it.
  def self.for(arm, line_item)
    liv = LineItemsVisit.where(arm_id: arm.id, line_item_id: line_item.id).first_or_create(subject_count: arm.subject_count)
    return liv
  end

  def create_visits
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
    return quantity_total * (self.subject_count || 0)
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

  # Return visits with R and T quantities
  # Used in service_request show.xlsx report
  def per_subject_rt_indicated(visits=self.visits)
    indicated_visits = {}
    visits.each do |visit|
      indicated_visits[visit.id.to_s] = visit.research_billing_qty + visit.insurance_billing_qty
    end

    return indicated_visits
  end

  # Determine the direct costs for a visit-based service for one subject
  def direct_costs_for_visit_based_service_single_subject
    result = Visit.where("line_items_visit_id = ? AND research_billing_qty >= ?", self.id, 1).sum(:research_billing_qty)
    research_billing_qty_total = result || 0
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

  ##TODO: This should not exist, arm.remove_visit does this correctly
  def remove_visit visit_group
    visit = self.visits.find_by_visit_group_id(visit_group.id)
    visit.delete
  end

  def procedures
    self.visits.map {|x| x.appointments.map {|y| y.procedures.select {|z| z.line_item_id == self.line_item_id}}}.flatten
  end

  def remove_procedures
    self.procedures.each do |pro|
      if pro.completed?
        if pro.line_item.service.displayed_pricing_map.unit_factor > 1
          pro.update_attributes(:unit_factor_cost => pro.cost * 100)
        end
        pro.update_attributes(service_id: self.line_item.service_id, line_item_id: nil, visit_id: nil)
      else
        pro.destroy
      end
    end
  end

  ### audit reporting methods ###

  def audit_excluded_actions
    ['create', 'update']
  end

  ### end audit reporting methods ###

  def any_visit_quantities_customized?
    visits.any?(&:quantities_customized?)
  end
end
