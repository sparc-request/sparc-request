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

class VisitGroup < ApplicationRecord
  self.per_page = Visit.per_page

  include RemotelyNotifiable
  include Comparable

  audited

  belongs_to :arm
  has_many :visits, :dependent => :destroy
  
  has_many :line_items_visits, through: :visits
  
  ########################
  ### CWF Associations ###
  ########################

  has_many :fulfillment_visit_groups, class_name: 'Shard::Fulfillment::VisitGroup', foreign_key: :sparc_id

  acts_as_list scope: :arm

  after_create :build_visits, if: Proc.new { |vg| vg.arm.present? }
  after_create :increment_visit_count, if: Proc.new { |vg| vg.arm.present? && vg.arm.visit_count < vg.arm.visit_groups.count }
  before_destroy :decrement_visit_count, if: Proc.new { |vg| vg.arm.present? && vg.arm.visit_count >= vg.arm.visit_groups.count  }

  validates :name, presence: true
  validates :position, presence: true
  validates :window_before,
            :window_after,
            presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :day, presence: true, numericality: { only_integer: true }

  validate :day_must_be_in_order

  default_scope { order(:position) }

  def <=> (other_vg)
    return unless other_vg.respond_to?(:day)
    self.day <=> other_vg.day
  end

  def self.admin_day_multiplier
    5
  end

  def insertion_name
    "Before #{name}" + (day.present? ? " (Day #{day})" : "")
  end

  ### audit reporting methods ###

  def audit_label audit
    "#{arm.name} #{name}"
  end

  def audit_field_value_mapping
    {"arm_id" => "Arm.find(ORIGINAL_VALUE).name"}
  end

  ### end audit reporting methods ###

  def any_visit_quantities_customized?(service_request)
    visits.any? { |visit| ((visit.quantities_customized?) && (visit.line_items_visit.line_item.service_request_id == service_request.id)) }
  end

  # TODO: remove after day_must_be_in_order validation is fixed.
  def in_order?
    arm.visit_groups.where("position < ? AND day >= ? OR position > ? AND day <= ?", position, day, position, day).none?
  end

  def per_patient_subtotals
    self.visits.sum{ |v| v.cost || 0.00 }
  end
    
  private

  def build_visits
    self.arm.line_items_visits.each do |liv|
      self.visits.create(line_items_visit: liv)
    end
  end

  def increment_visit_count
    self.arm.increment!(:visit_count)
  end

  def decrement_visit_count
    self.arm.decrement!(:visit_count)
  end

  def day_must_be_in_order
    unless in_order?
      errors.add(:day, 'must be in order')
    end
  end
end
