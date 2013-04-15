class Calendar < ActiveRecord::Base
  belongs_to :subject
  has_many :appointments

  def populate(visit_groups)
    visit_groups.each do |visit_group|
      appt = self.appointments.create(:visit_group => visit_group)
      appt.populate_procedures(visit_group.visits)
    end
  end
  
end
