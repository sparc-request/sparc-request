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
  
  before_save :move_consecutive_visit, if: Proc.new{ |vg| vg.moved_and_days_need_update? }

  before_destroy :decrement_visit_count, if: Proc.new { |vg| vg.arm.present? && vg.arm.visit_count >= vg.arm.visit_groups.count  }

  validates :name, :position, :day, :window_before, :window_after, presence: true

  validates :position, presence: true
  validates :window_before, :window_after, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: Proc.new{ |vg| vg.day.present? }

  validates :day, numericality: { only_integer: true }, if: Proc.new{ |vg| vg.day.present? }

  validate :day_must_be_in_order, if: Proc.new{ |vg| vg.day.present? }

  default_scope { order(:position) }

  def <=> (other_vg)
    return unless other_vg.respond_to?(:day)
    self.day <=> other_vg.day
  end

  def position=(position)
    if position.blank?
      write_attribute(:position, nil)
    elsif self.arm && position == self.arm.visit_count || self.position == position.to_i
      write_attribute(:position, position)
    else
      # Because we have to insert before using position - 1,
      # increment position when changed
      write_attribute(:position, position.to_i + 1)
    end
  end

  def identifier
    "#{self.name}" + (self.day.present? ? " (#{self.class.human_attribute_name(:day)} #{self.day})" : "")
  end

  def insertion_name
    I18n.t('visit_groups.before') + " " + self.identifier
  end

  ### audit reporting methods ###

  def audit_label audit
    "#{arm.name} #{name}"
  end

  def audit_field_value_mapping
    {"arm_id" => "Arm.find(ORIGINAL_VALUE).name"}
  end

  ### end audit reporting methods ###

  def moved_and_days_need_update?
    # Three Cases:
    # The Visit Group is new and is being inserted between two other consecutive-day visits
    # The Visit Group had a nil day but is between two consecutive-day visits and needs to move one
    # The Visit Group has been moved and now we need to move consecutive visits
    @moved_and_update ||= (self.new_record? && self.arm && self.day && self.day == self.arm.visit_groups.where(VisitGroup.arel_table[:position].gteq(self.position)).minimum(:day)) ||
                          (self.persisted? && day_changed? && self.day == self.lower_items.where.not(id: self.id, day: nil).minimum(:day)) ||
                          (self.persisted? && position_changed? && day_changed? && self.day == self.arm.visit_groups.find_by(position: self.position).try(:day))
  end

  def in_order?
    self.arm.visit_groups.where.not(id: self.id, day: nil).where(
      VisitGroup.arel_table[:position].lt(self.position).and(
      VisitGroup.arel_table[:day].gteq(self.day)).or(
      VisitGroup.arel_table[:position].gt(self.position).and(
      VisitGroup.arel_table[:day].lteq(self.day)))
    ).none?
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

  def move_consecutive_visit
    # The Visit Group has been moved and now we need to move consecutive visits
    if self.position_changed?
      if vg = self.arm.visit_groups.find_by(position: self.position)
        # This actually increments position when position= is called
        vg.update_attributes(day: vg.day.try(:+, 1), position: vg.position)
      end
    else # The Visit Group had a nil day but is between two consecutive-day visits and needs to move one
      if vg = self.lower_items.where.not(id: self.id, day: nil).first
        vg.update_attributes(day: vg.day.try(:+, 1), position: vg.position - 1)
      end
    end
  end

  def day_must_be_in_order
    errors.add(:day, :out_of_order) unless moved_and_days_need_update? || in_order?
  end
end
