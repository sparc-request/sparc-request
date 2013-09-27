class VisitGroup < ActiveRecord::Base
  include Comparable
  audited

  belongs_to :arm
  has_many :visits, :dependent => :destroy
  has_many :appointments
  attr_accessible :name
  attr_accessible :position
  attr_accessible :arm_id
  attr_accessible :day
  attr_accessible :window
  acts_as_list :scope => :arm

  after_create :set_default_name
  before_destroy :remove_appointments

  def set_default_name
    if name.nil? || name == ""
      self.update_attributes(:name => "Visit #{self.position}")
    end
  end

  def <=> (other_vg)
    return self.day <=> other_vg.day
  end
  
  ### audit reporting methods ###
  
  def audit_label audit
    "#{arm.name} #{name}"
  end

  ### end audit reporting methods ###


  private

  def remove_appointments
    appointments = self.appointments
    appointments.each do |app|
      if app.completed?
        app.update_attributes(position: self.position, name: self.name, visit_group_id: nil)
      else
        app.destroy
      end
    end
  end

end
