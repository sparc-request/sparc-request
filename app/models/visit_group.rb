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

class VisitGroup < ApplicationRecord
  self.per_page = Visit.per_page

  include RemotelyNotifiable
  include Comparable

  audited
  belongs_to :arm
  has_many :visits, :dependent => :destroy
  has_many :line_items_visits, through: :visits
  has_many :appointments

  acts_as_list scope: :arm

  after_save :set_arm_edited_flag_on_subjects
  before_destroy :remove_appointments

  validates :name, presence: true
  validates :position, presence: true
  validates :window_before,
            :window_after,
            presence: true, numericality: { only_integer: true }
  validates :day, presence: true, numericality: { only_integer: true }

  validate :day_must_be_in_order

  def set_arm_edited_flag_on_subjects
    self.arm.set_arm_edited_flag_on_subjects
  end

  def <=> (other_vg)
    return unless other_vg.respond_to?(:day)
    self.day <=> other_vg.day
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

  private

  def remove_appointments
    appointments = self.appointments
    appointments.each do |app|
      if app.completed?
        app.update_attributes(position: self.position, name: self.name, visit_group_id: nil)
      else
        app.destroy
      end
    end
  end

  def day_must_be_in_order
    unless in_order?
      errors.add(:day, 'must be in order')
    end
  end
end
