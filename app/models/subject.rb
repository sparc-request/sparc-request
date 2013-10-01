class Subject < ActiveRecord::Base
  audited

  belongs_to :arm
  has_one :calendar, :dependent => :destroy

  attr_accessible :name
  attr_accessible :mrn
  attr_accessible :dob
  attr_accessible :gender
  attr_accessible :ethnicity
  attr_accessible :external_subject_id
  attr_accessible :calendar_attributes
  attr_accessible :status

  accepts_nested_attributes_for :calendar

  after_create { self.create_calendar }

  def label
    label = nil

    if not mrn.blank?
      label = "Subject MRN:#{mrn}"
    end

    if not external_subject_id.blank?
      label = "Subject ID:#{external_subject_id}"
    end

    label
  end

  ### audit reporting methods ###
  
  def audit_field_replacements
    {"external_subject_id" => "PARTICIPANT ID"}
  end

  def audit_excluded_fields
    {'create' => ['arm_id']}
  end

  def audit_label audit
    self.label || "Subject #{id}"
  end

  ### end audit reporting methods ###
  
  def procedures
    appointments = Appointment.where("calendar_id = ?", self.calendar.id).includes(:procedures)
    procedures = appointments.collect{|x| x.procedures}.flatten
  end
end
