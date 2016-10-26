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

class Calendar < ActiveRecord::Base
  audited

  belongs_to :subject
  has_many :appointments, :dependent => :destroy

  attr_accessible :appointments_attributes

  accepts_nested_attributes_for :appointments

  def populate(visit_groups)
    core_ids = []
    visit_groups.each do |visit_group|
      visit_group.visits.each do |visit|
        line_item = visit.line_items_visit.line_item
        next unless line_item.attached_to_submitted_request
        core = line_item.service.organization
        core_ids << core.id if core.tag_list.include?("clinical work fulfillment")
      end
    end
    core_ids.uniq!

    visit_groups.each do |visit_group|
      core_ids.each do |core_id|
        appt = self.appointments.create(visit_group_id: visit_group.id, organization_id: core_id)
        visits = visit_group.visits.select {|x| x.line_items_visit.line_item.service.organization_id == core_id and x.line_items_visit.line_item.attached_to_submitted_request}
        appt.populate_procedures(visits)
      end
    end
  end

  # This will fix and populate old appointments if a request is edited
  def populate_on_request_edit
    columns = [:line_item_id,:visit_id,:appointment_id]
    values = []
    if self.subject.arm_edited
      arm = self.subject.arm
      appointments = Appointment.where(calendar_id: self.id).includes(procedures: :visit)
      appointments.each do |appointment|
        if appointment.visit_group_id
          appointment_id = appointment.id
          existing_liv_ids = appointment.procedures.map {|x| x.visit ? x.visit.line_items_visit.id : nil}.compact
          new_livs = arm.line_items_visits.reject {|x| existing_liv_ids.include?(x.id)}
          new_livs.each do |new_liv|
            visit = new_liv.visits.where("visit_group_id = ?", appointment.visit_group_id).first
            if !(new_liv.line_item.service.one_time_fee) && (new_liv.line_item.service.organization_id == appointment.organization_id)
              values<<[new_liv.line_item.id, visit.id, appointment_id]
            end
          end
        end
      end
      if !(values.empty?)
        Procedure.import columns, values, {:validate => true}
      end
      self.reload
      self.subject.update_attributes(arm_edited: false)
    end
  end

  def visit_group_count
    visit_group_ids = []
    self.appointments.each do |appt|
      visit_group_ids << appt.visit_group.id if appt.visit_group
    end

    visit_group_ids.uniq.count
  end

  def build_subject_data
    if self.appointments.empty? || (self.subject.arm.visit_groups.count > self.visit_group_count)
      subject = self.subject
      groups = VisitGroup.where(arm_id: subject.arm.id).includes(visits: { line_items_visit: :line_item })
      filtered_groups = groups.select{ |vg| !vg.appointments.map(&:calendar_id).include?(self.id) }
      self.populate(filtered_groups)
    end
  end

  def completed_total
    completed_procedures = self.appointments.select{|x| x.completed?}.collect{|y| y.procedures}.flatten
    return completed_procedures.select{|x| x.appointment.completed_for_core?(x.core.id)}.sum{|x| x.total}
  end

  def appointments_for_core core_id
    self.appointments.where(:organization_id => core_id)
  end

  ### audit reporting methods ###

  def audit_excluded_fields
    {'create' => ['subject_id']}
  end

  ### end audit reporting methods ###
end
