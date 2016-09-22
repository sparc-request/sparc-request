# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
