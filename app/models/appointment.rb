class Appointment < ActiveRecord::Base
  belongs_to :calendar
  belongs_to :visit_group
  belongs_to :service
  has_many :procedures
  has_many :visits, :through => :procedures
  attr_accessible :visit_group_id


  def populate_procedures(visits)
    visits.each do |visit|
      line_item = visit.line_items_visit.line_item
      service = line_item.service
      procedure = self.procedures.build(:line_item_id => line_item.id, :visit_id => visit.id, :service_id => service.id)
      procedure.required = visit.to_be_performed?
      procedure.save
    end
  end
end
