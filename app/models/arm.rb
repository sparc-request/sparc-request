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
class Arm < ApplicationRecord

  include RemotelyNotifiable

  audited

  belongs_to :protocol
  has_many :line_items_visits, :dependent => :destroy
  has_many :visit_groups, -> { order("position") }, :dependent => :destroy

  has_many :line_items, :through => :line_items_visits
  has_many :sub_service_requests, through: :line_items
  has_many :visits, :through => :line_items_visits

  ########################
  ### CWF Associations ###
  ########################

  has_many :fulfillment_arms, class_name: 'Shard::Fulfillment::Arm', foreign_key: :sparc_id

  after_create :create_calendar_objects, if: Proc.new { |arm| arm.protocol.present? }
  after_update :update_visit_groups
  after_update :update_liv_subject_counts

  validates :name, presence: true
  validate :name_formatted_properly
  validate :name_unique_to_protocol

  validates :visit_count, numericality: { greater_than: 0 }
  validates :subject_count, numericality: { greater_than: 0 }

  def name=(name)
    write_attribute(:name, name.squish)
  end

  def display_line_items_visits(display_all_services)
    if Setting.get_value('use_epic')
      # only show the services that are set to be pushed to Epic
      if display_all_services
        self.line_items_visits.joins(:service).where.not(services: { cpt_code: [nil, ''] })
      else
        self.line_items_visits.joins(:service, :visits).where.not(services: { cpt_code: [nil, ''] }).where(Visit.arel_table[:research_billing_qty].gt(0).or(Visit.arel_table[:insurance_billing_qty].gt(0)).or(Visit.arel_table[:effort_billing_qty].gt(0))).distinct
      end
    else
      if display_all_services
        self.line_items_visits
      else
        self.line_items_visits.joins(:visits).where(Visit.arel_table[:research_billing_qty].gt(0).or(Visit.arel_table[:insurance_billing_qty].gt(0)).or(Visit.arel_table[:effort_billing_qty].gt(0))).distinct
      end
    end
  end

  def name_formatted_properly
    if !name.blank? && name.match(/\A([ ]*[A-Za-z0-9``~!@#$%^&()\-_+={}|<>.,;'"][ ]*)+\z/).nil?
      errors.add(:name, I18n.t(:errors)[:arms][:bad_characters])
    end
  end

  def name_unique_to_protocol
    arm_names = self.protocol.arms.where.not(id: self.id).pluck(:name)
    arm_names = arm_names.map(&:downcase)

    errors.add(:name, I18n.t(:errors)[:arms][:name_unique]) if arm_names.include?(self.name.downcase)
  end

  def per_patient_per_visit_line_items
    line_items_visits.each.map do |liv|
      liv.line_item
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
    if Setting.get_value("use_indirect_cost")
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
    if Setting.get_value("use_indirect_cost")
      line_items_visits.each do |vg|
        total += vg.indirect_costs_for_visit_based_service
      end
    end
    return total
  end

  def total_costs_for_visit_based_service line_items_visits=self.line_items_visits
    direct_costs_for_visit_based_service(line_items_visits) + indirect_costs_for_visit_based_service(line_items_visits)
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
      service.parents.each do |parent|
        next if !parent.process_ssrs? && !found_parent
        found_parent = true
        last_parent = last_parent || parent.id
        last_parent_name = last_parent_name || parent.name
        name << parent.abbreviation
        acks << parent.ack_language unless parent.ack_language.blank?
      end
      if found_parent == false
        service.parents.each do |parent|
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
      vg.update_attributes(day: vg.position * VisitGroup.admin_day_multiplier)
    end
  end

  ### audit reporting methods ###

  def audit_label audit
    name
  end

  ### end audit reporting methods ###

  private

  def create_calendar_objects
    mass_create_visit_groups

    self.protocol.service_requests.flat_map(&:per_patient_per_visit_line_items).each do |li|
      self.line_items_visits.create(line_item: li, subject_count: self.subject_count)
    end

    self.reload
  end

  def update_visit_groups
    if self.visit_count > self.visit_groups.count
      mass_create_visit_groups
    elsif self.visit_count < self.visit_groups.count
      mass_destroy_visit_groups
    end
  end

  def update_liv_subject_counts
    self.line_items_visits.each do |liv|
      if !liv.subject_count.present? && liv.line_item.sub_service_request.can_be_edited?
        liv.update_attributes(subject_count: self.subject_count)
      end
    end
  end

  def mass_create_visit_groups
    last_position = self.visit_groups.any? ? self.visit_groups.last.position : 0
    position      = last_position + 1
    count         = self.visit_count - last_position

    count.times do |index|
      self.visit_groups.new(name: "Visit #{position}", position: position).save(validate: false)
      position += 1
    end
  end

  def mass_destroy_visit_groups
    self.visit_groups.where("position > ?", self.visit_count).destroy_all
  end
end
