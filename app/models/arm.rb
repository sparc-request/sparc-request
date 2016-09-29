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
class Arm < ActiveRecord::Base

  include RemotelyNotifiable

  audited

  belongs_to :protocol

  has_many :line_items_visits, :dependent => :destroy
  has_many :line_items, :through => :line_items_visits
  has_many :subjects
  has_many :visit_groups, -> { order("position") }, :dependent => :destroy
  has_many :visits, :through => :line_items_visits

  attr_accessible :name
  attr_accessible :visit_count
  attr_accessible :subject_count      # maximum number of subjects for any visit grouping
  attr_accessible :new_with_draft     # used for existing arm validations in sparc proper (should always be false unless in first draft)
  attr_accessible :subjects_attributes
  attr_accessible :protocol_id
  attr_accessible :minimum_visit_count
  attr_accessible :minimum_subject_count
  accepts_nested_attributes_for :subjects, allow_destroy: true

  after_save :update_liv_subject_counts

  validates :name, presence: true
  validates_uniqueness_of :name, scope: :protocol
  validates :visit_count, numericality: { greater_than: 0 }
  validates :subject_count, numericality: { greater_than: 0 }

  validate do |arm|
    arm.visit_groups.each do |visit_group|
      if !visit_group.valid? && visit_group.errors.full_messages.first.include?('order')
        errors[:base] << visit_group.errors.full_messages.first
      end
    end
  end

  def sanitized_name
    #Sanitized for Excel
    name.gsub(/\[|\]|\*|\/|\\|\?|\:/, ' ')
  end

  def update_liv_subject_counts

    self.line_items_visits.each do |liv|
      if ['first_draft', 'draft', nil].include?(liv.line_item.service_request.status)
        liv.update_attributes(:subject_count => self.subject_count)
      end
    end
  end

  def valid_visit_count?
    return !visit_count.nil? && visit_count > 0
  end

  def valid_subject_count?
    return !subject_count.nil? && subject_count > 0
  end

  def valid_name?
    return !name.nil? && name.length > 0
  end

  def create_line_items_visit line_item
    # if visit_count is nil then set it to 1
    self.update_attribute(:visit_count, 1) if self.visit_count.nil?

    create_visit_groups(visit_count)
    liv = LineItemsVisit.for(self, line_item)
    liv.create_visits

    if line_items_visits.count > 1
      liv.update_visit_names self.line_items_visits.first
    end
  end

  def per_patient_per_visit_line_items
    line_items_visits.each.map do |vg|
      vg.line_item
    end.compact
  end

  def maximum_direct_costs_per_patient line_items_visits=self.line_items_visits
    total = 0.0
    line_items_visits.each do |liv|
      total += liv.direct_costs_for_visit_based_service_single_subject
    end

    total
  end

  def maximum_indirect_costs_per_patient line_items_visits=self.line_items_visits
    if USE_INDIRECT_COST
      self.maximum_direct_costs_per_patient(line_items_visits) * (self.protocol.indirect_cost_rate.to_f / 100)
    else
      return 0
    end
  end

  def maximum_total_per_patient line_items_visits=self.line_items_visits
    self.maximum_direct_costs_per_patient(line_items_visits) + maximum_indirect_costs_per_patient(line_items_visits)
  end

  def direct_costs_for_visit_based_service line_items_visits=self.line_items_visits
    total = 0.0
    line_items_visits.each do |vg|
      total += vg.direct_costs_for_visit_based_service
    end
    return total
  end

  def indirect_costs_for_visit_based_service line_items_visits=self.line_items_visits
    total = 0.0
    if USE_INDIRECT_COST
      line_items_visits.each do |vg|
        total += vg.indirect_costs_for_visit_based_service
      end
    end
    return total
  end

  def total_costs_for_visit_based_service line_items_visits=self.line_items_visits
    direct_costs_for_visit_based_service(line_items_visits) + indirect_costs_for_visit_based_service(line_items_visits)
  end

  def add_visit position=self.visit_groups.count+1, day=position-1, window_before=0, window_after=0, name="Visit #{day}", portal=false
    result = self.transaction do
      if not self.create_visit_group(position, name, day) then
        raise ActiveRecord::Rollback
      end
      position = position.to_i-1 unless position.blank?
      if USE_EPIC
        if not self.update_visit_group_day(day, position, portal) then
          raise ActiveRecord::Rollback
        end
        if not self.update_visit_group_window_before(window_before, position, portal) then
          raise ActiveRecord::Rollback
        end
        if not self.update_visit_group_window_after(window_after, position, portal) then
          raise ActiveRecord::Rollback
        end
      end
      # Reload to force refresh of the visits
      self.reload

      self.visit_count ||= 0 # in case we import a service request with nil visit count
      self.visit_count += 1

      self.save or raise ActiveRecord::Rollback
    end

    if result then
      return true
    else
      self.reload
      return false
    end
  end

  def create_visit_group position=self.visit_groups.count+1, name="Visit #{position-1}", day=position-1
    if not visit_group = self.visit_groups.create(position: position, name: name, day: day, arm_id: self.id) then
      return false
    end
    # Add visits to each line item under the service request
    self.line_items_visits.each do |liv|
      if not liv.add_visit(visit_group) then
        self.errors.initialize_dup(liv.errors) # TODO: is this the right way to do this?
        return false
      end
    end
    self.reload
    return visit_group
  end

  def mass_create_visit_group
    visit_count = self.visit_count

    create_visit_groups(visit_count)
    vg_ids = get_visit_group_ids
    create_visits(vg_ids)
  end

  def mass_destroy_visit_group
    self.visit_groups.where("position > #{self.visit_count}").destroy_all
  end

  def remove_visit position
    visit_group = self.visit_groups.find_by_position(position)
    if visit_group
      self.update_attributes(:visit_count => self.visit_count - 1)
      return visit_group.destroy
    else
      return false
    end
  end

  def populate_subjects
    subject_difference = self.subject_count - self.subjects.count

    if subject_difference > 0
      subject_difference.times do
        self.subjects.create
      end
    end
  end

  def set_arm_edited_flag_on_subjects
    if self.subjects
      subjects = Subject.where(arm_id: self.id)
      subjects.update_all(arm_edited: true)
    end
  end

  def update_visit_group_day day, position, portal=false
    position = position.blank? ? self.visit_groups.count - 1 : position.to_i
    before = self.visit_groups[position - 1] unless position == 0
    current = self.visit_groups[position]
    after = self.visit_groups[position + 1] unless position >= self.visit_groups.size - 1
    if portal == 'true' and USE_EPIC
      valid_day = Integer(day) rescue false
      if !valid_day
        self.errors.add(:invalid_day, "You've entered an invalid number for the day. Please enter a valid number.")
        return false
      end
      if !before.nil? && !before.day.nil?
        if before.day > valid_day
          self.errors.add(:out_of_order, "The days are out of order. This day appears to go before the previous day.")
          return false
        end
      end

      if !after.nil? && !after.day.nil?
        if valid_day > after.day
          self.errors.add(:out_of_order, "The days are out of order. This day appears to go after the next day.")
          return false
        end
      end
    end
    return current.update_attributes(:day => day)
  end

  def update_visit_group_window_before window_before, position, portal = false
    position = position.blank? ? self.visit_groups.count - 1 : position.to_i
    valid = Integer(window_before) rescue false
    if !valid || valid < 0
      self.errors.add(:invalid_window_before, "You've entered an invalid number for the before window. Please enter a positive valid number")
      return false
    end

    visit_group = self.visit_groups[position]
    return visit_group.update_attributes(:window_before => window_before)
  end

  def update_visit_group_window_after window_after, position, portal = false
    position = position.blank? ? self.visit_groups.count - 1 : position.to_i
    valid = Integer(window_after) rescue false
    if !valid || valid < 0
      self.errors.add(:invalid_window_after, "You've entered an invalid number for the after window. Please enter a positive valid number")
      return false
    end

    visit_group = self.visit_groups[position]
    return visit_group.update_attributes(:window_after => window_after)
  end

  def service_list
    items = self.line_items_visits.map do |liv|
      liv.line_item.service.one_time_fee ? nil : liv.line_item
    end.compact
    groupings = {}
    items.each do |line_item|
      service = line_item.service
      name = []
      acks = []
      last_parent = nil
      last_parent_name = nil
      found_parent = false
      service.parents.reverse.each do |parent|
        next if !parent.process_ssrs? && !found_parent
        found_parent = true
        last_parent = last_parent || parent.id
        last_parent_name = last_parent_name || parent.name
        name << parent.abbreviation
        acks << parent.ack_language unless parent.ack_language.blank?
      end
      if found_parent == false
        service.parents.reverse.each do |parent|
          name << parent.abbreviation
          acks << parent.ack_language unless parent.ack_language.blank?
        end
        last_parent = service.organization.id
        last_parent_name = service.organization.name
      end

      if groupings.include? last_parent
        g = groupings[last_parent]
        g[:services] << service
        g[:line_items] << line_item
      else
        groupings[last_parent] = {:process_ssr_organization_name => last_parent_name, :name => name.reverse.join(' -- '), :services => [service], :line_items => [line_item], :acks => acks.reverse.uniq.compact}
      end
    end

    groupings
  end

  def update_minimum_counts
    self.update_attributes(:minimum_visit_count => self.visit_count, :minimum_subject_count => self.subject_count)
  end

  def default_visit_days
    self.visit_groups.each do |vg|
      vg.update_attribute(:day, vg.position*5)
    end
    reload
  end

  ### audit reporting methods ###

  def audit_label audit
    name
  end

  ### end audit reporting methods ###

  private

  def create_visit_groups(visit_count)
    if visit_groups.empty?
      last_position = 0
    else
      last_position = visit_groups.last.position
    end
    count = visit_count - last_position
    count.times do |index|
      position = last_position + 1
      visit_group = VisitGroup.new(arm_id: self.id, name: "Visit #{position}", position: position)
      visit_group.save(validate: false)
      last_position += 1
    end
    self.reload
  end

  def get_visit_group_ids
    vg_ids = []
    self.visit_groups.each do |vg|
      if vg.visits.count == 0
        vg_ids << vg.id
      end
    end

    vg_ids
  end

  def create_visits(vg_ids)
    self.line_items_visits.each do |liv|
      vg_ids.each do |id|
        Visit.create(visit_group_id: id, line_items_visit_id: liv.id)
      end
    end
    self.reload
  end
end
