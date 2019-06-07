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

class LineItemsVisit < ApplicationRecord

  include RemotelyNotifiable

  audited

  belongs_to :arm
  belongs_to :line_item

  has_many :visits, :dependent => :destroy
  has_many :ordered_visits, -> { ordered }, class_name: "Visit"
  has_many :notes, as: :notable, dependent: :destroy

  has_many :visit_groups, through: :visits

  has_one :service_request, through: :line_item
  has_one :sub_service_request, through: :line_item
  has_one :service, through: :line_item

  validate :subject_count_valid
  validate :pppv_line_item
  validates_numericality_of :subject_count

  after_create :build_visits, if: Proc.new { |liv| liv.arm.present? }

  # Destroy parent Arm if the last LineItemsVisit was destroyed
  after_destroy :release_parent

  def subject_count_valid
    if subject_count && subject_count > arm.subject_count
      errors.add(:blank, I18n.t('errors.line_items_visits.subject_count_invalid', arm_subject_count: arm.subject_count))
    end
  end

  def pppv_line_item
    if self.line_item.one_time_fee
      errors.add(:_, 'Line Items Visits should only belong to a PPPV LineItem')
    end
  end

  # Find a LineItemsVisit for the given arm and line item.  If it does
  # not exist, create it first, then return it.
  def self.for(arm, line_item)
    liv = LineItemsVisit.where(arm_id: arm.id, line_item_id: line_item.id).first_or_create(subject_count: arm.subject_count)
    return liv
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
    self.line_item.service.displayed_pricing_map.unit_factor || 1
  end

  def quantity_total
    sum_visits_research_billing_qty * (self.subject_count || 0)
  end

  # Returns a hash of subtotals for the visits in the line item.
  # Visit totals depend on the quantities in the other visits, so it would be clunky
  # to compute one visit at a time
  def per_subject_subtotals(visits=self.ordered_visits)
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
  def per_subject_rt_indicated(visits=self.ordered_visits)
    indicated_visits = {}
    visits.each do |visit|
      indicated_visits[visit.id.to_s] = visit.research_billing_qty + visit.insurance_billing_qty
    end

    return indicated_visits
  end

  # Determine the direct costs for a visit-based service for one subject
  def direct_costs_for_visit_based_service_single_subject
    sum_visits_research_billing_qty_gte_1 * per_unit_cost(quantity_total())
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
    if Setting.get_value("use_indirect_cost")
      self.line_item.service_request.protocol.indirect_cost_rate.to_f / 100
    else
      return 0
    end
  end

  # Determine the indirect cost rate for a visit-based service for one subject
  def indirect_costs_for_visit_based_service_single_subject
    if Setting.get_value("use_indirect_cost")
      self.direct_costs_for_visit_based_service_single_subject * self.indirect_cost_rate
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
    if self.line_item.service.displayed_pricing_map.exclude_from_indirect_cost || !Setting.get_value("use_indirect_cost")
      return 0
    else
      self.direct_costs_for_one_time_fee * self.indirect_cost_rate
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

  private

  def build_visits
    self.arm.visit_groups.each do |vg|
      self.visits.create(visit_group: vg)
    end
  end

  def release_parent
    # Destroy parent Arm if the last LineItemsVisit was destroyed
    if LineItemsVisit.where(arm_id: arm_id).none?
      Arm.find(arm_id).destroy
    end
  end

  def sum_visits_research_billing_qty
    @research_billing_total ||= 
      if self.visits.loaded?
        self.visits.sum(&:research_billing_qty) || 0
      else
        self.visits.sum(:research_billing_qty) || 0
      end
  end

  def sum_visits_research_billing_qty_gte_1
    @research_billing_gte1_total ||= self.visits.where("research_billing_qty >= ?", 1).sum(:research_billing_qty) || 0
  end
end
