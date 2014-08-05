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

  # This will fix and populate old appointments if a request is edited
  def populate_on_request_edit
    if self.subject.arm_edited
      arm = self.subject.arm
      appointments = Appointment.where(calendar_id: self.id).includes(procedures: :visit)
      appointments.each do |appointment|
        if appointment.visit_group_id
          existing_liv_ids = appointment.procedures.map {|x| x.visit ? x.visit.line_items_visit.id : nil}.compact
          new_livs = arm.line_items_visits.reject {|x| existing_liv_ids.include?(x.id)}
          new_livs.each do |new_liv|
            visit = new_liv.visits.where("visit_group_id = ?", appointment.visit_group_id).first
            if (new_liv.line_item.service.organization_id == appointment.organization_id) && !new_liv.line_item.service.is_one_time_fee?
              appointment.procedures.create(:line_item_id => new_liv.line_item.id, :visit_id => visit.id)
            end
          end
        end
      end
      self.subject.update_attributes(arm_edited: false)
    end
  end

  def visit_group_count
    visit_group_ids = []
    self.appointments.each do |appt|
      visit_group_ids << appt.visit_group.id
    end

    visit_group_ids.uniq.count
  end

  def build_subject_data
    if self.appointments.empty? || (self.subject.arm.visit_groups.count > self.visit_group_count)
      subject = self.subject
      groups = VisitGroup.where(arm_id: subject.arm.id).includes(visits: { line_items_visit: :line_item })
      groups = groups.select{|x| x.appointments.empty?}

      self.populate(groups)
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
