class Appointment < ActiveRecord::Base
  audited

  belongs_to :calendar
  belongs_to :visit_group
  belongs_to :service
  has_many :procedures
  has_many :visits, :through => :procedures
  has_many :notes
  has_many :appointment_completions, :dependent => :destroy
  attr_accessible :visit_group_id
  attr_accessible :completed_at

  attr_accessible :procedures_attributes
  attr_accessible :appointment_completions_attributes

  accepts_nested_attributes_for :procedures
  accepts_nested_attributes_for :appointment_completions

  after_create :create_appointment_completions


  def populate_procedures(visits)
    visits.each do |visit|
      line_item = visit.line_items_visit.line_item
      procedure = self.procedures.build(:line_item_id => line_item.id, :visit_id => visit.id)
      procedure.save
    end
  end

  # TODO
  # Update this method when the new core specific completed dates are added
  def completed? (core_id)
    if self.completed_at(core_id).first.try(:completed_date)
      return true
    else
      return false
    end
  end

  def completed_at (core_id)
    AppointmentCompletion.where("organization_id = ? AND appointment_id = ?", core_id, self.id)
  end

  def create_appointment_completions
    cores = []
    cores << nutrition = Organization.tagged_with("nutrition").first
    cores << nursing   = Organization.tagged_with("nursing").first
    cores << lab       = Organization.tagged_with("laboratory").first
    cores << imaging   = Organization.tagged_with("imaging").first

    cores.each do |core|
      self.appointment_completions.create(:organization_id => core.id)
    end
  end
end
