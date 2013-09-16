class Calendar < ActiveRecord::Base
  audited

  belongs_to :subject
  has_many :appointments

  attr_accessible :appointments_attributes

  accepts_nested_attributes_for :appointments

  def populate(visit_groups)
    visit_groups.each do |visit_group|
      appt = self.appointments.create(visit_group_id: visit_group.id)
      appt.populate_procedures(visit_group.visits)
    end
  end

  def core_completed_total(core)
    completed_appointments = self.appointments.select{|x| x.completed?(core)}
    completed_procedures = completed_appointments.collect{|x| x.procedures.select{|y| y.core == core}}.flatten

    return completed_procedures.sum{|x| x.total}
  end
  
end
