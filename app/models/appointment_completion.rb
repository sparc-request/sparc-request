class AppointmentCompletion < ActiveRecord::Base
  audited

  belongs_to :appointment
  belongs_to :organization
  attr_accessible :completed_date
  attr_accessible :organization_id
  attr_accessible :formatted_completed_date

  def formatted_completed_date
    format_date self.completed_date
  end
  def formatted_completed_date=(d)
    self.completed_date = parse_date(d)
  end
  
  ### audit reporting methods ###
 
  def audit_field_value_mapping
    {"completed_date" => "'ORIGINAL_VALUE'.to_time.strftime('%Y-%m-%d')"}
  end

  def audit_excluded_fields
    {"create" => ['appointment_id', 'organization_id']}
  end

  def audit_label audit
    subject = appointment.calendar.subject
    subject_label = subject.respond_to?(:audit_label) ? subject.audit_label(audit) : "Subject #{subject.id}"
    "#{appointment.visit_group.name} #{organization.abbreviation} Appointment Completed for #{subject_label}"
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
