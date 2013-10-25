class Note < ActiveRecord::Base
  audited

  belongs_to :identity
  belongs_to :sub_service_request
  belongs_to :appointment

  attr_accessible :body, :identity_id, :sub_service_request_id

  validates_presence_of :body
  
  ### audit reporting methods ###
    
  def audit_label audit
    subject = appointment.calendar.subject
    subject_label = subject.respond_to?(:audit_label) ? subject.audit_label(audit) : "Subject #{subject.id}"
    return "Note for #{subject_label} on #{appointment.visit_group.name}"
  end
 
  def audit_excluded_fields
    {'create' => ['identity_id', 'appointment_id']}
  end

  ### end audit reporting methods ###
end
