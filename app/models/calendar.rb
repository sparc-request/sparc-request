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
        core_ids << core.id if core.show_in_cwf
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
