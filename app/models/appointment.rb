class Appointment < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :visit_group
  belongs_to :service
  has_many :procedures
  has_many :visits, :through => :procedures


  def populate_procedures(visits)
    visits.each do |visit|
      service = visit.line_items_visit.line_item.service
      procedure = self.procedures.build(:visit => visit, :service => service)
      procedure.required = visit.to_be_performed?
      procedure.save
    end
  end
end
