class Appointment < ActiveRecord::Base
  audited

  belongs_to :calendar
  belongs_to :visit_group
  belongs_to :service
  has_many :procedures
  has_many :visits, :through => :procedures
  has_many :notes
  attr_accessible :visit_group_id
  attr_accessible :completed_at

  attr_accessible :procedures_attributes

  accepts_nested_attributes_for :procedures


  def populate_procedures(visits)
    visits.each do |visit|
      line_item = visit.line_items_visit.line_item
      procedure = self.procedures.build(:line_item_id => line_item.id, :visit_id => visit.id)
      procedure.save
    end
  end

  # TODO
  # Update this method when the new core specific completed dates are added
  def completed?
    self.completed_at?
  end
end
