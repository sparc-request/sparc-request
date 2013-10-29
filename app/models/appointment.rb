class Appointment < ActiveRecord::Base
  audited

  belongs_to :calendar
  belongs_to :visit_group
  has_many :procedures, :dependent => :destroy
  has_many :visits, :through => :procedures
  has_many :notes
  attr_accessible :visit_group_id
  attr_accessible :organization_id
  attr_accessible :completed_at
  attr_accessible :position
  attr_accessible :name

  attr_accessible :procedures_attributes

  accepts_nested_attributes_for :procedures

  attr_accessible :formatted_completed_date

  def formatted_completed_date
    format_date self.completed_at
  end

  def formatted_completed_date=(d)
    self.completed_at = parse_date(d)
  end


  def populate_procedures(visits)
    visits.each do |visit|
      line_item = visit.line_items_visit.line_item
      if line_item.service.is_ctrc?
        procedure = self.procedures.build(:line_item_id => line_item.id, :visit_id => visit.id, :toasts_generated => true)
        procedure.save
      end
    end
  end

  def position_switch
    self.visit_group ? self.visit_group.position : self.position
  end

  def name_switch
    self.visit_group ? self.visit_group.name : self.name
  end

  def completed?
    if self.completed_at
      true
    else
      false
    end
  end
  
  # TODO
  # Update this method when the new core specific completed dates are added
  def completed_for_core? (core_id)
    self.completed?
  end

  # def create_appointment_completions
  #   cores = []
  #   cores = Organization.where(show_in_cwf: true)

  #   cores.each do |core|
  #     if self.appointment_completions.where(:organization_id => core.id).empty?
  #       self.appointment_completions.create(:organization_id => core.id) 
  #     end
  #   end
  # end

  def display_name
    name_switch 
  end
  
  ### audit reporting methods ###
 
  def audit_label
    name_switch
  end

  def audit_field_value_mapping
    {"completed_at" => "'ORIGINAL_VALUE'.to_time.strftime('%Y-%m-%d')"}
  end
    
  def audit_excluded_actions
    ['create']
  end
  
  ### end audit reporting methods ###

  private

  def format_date(d)
    d.try(:strftime, '%-m/%d/%Y')
  end

  def parse_date(str)
    begin
      Date.strptime(str.to_s.strip, '%m/%d/%Y')  
    rescue ArgumentError => e
      nil
    end
  end


end
