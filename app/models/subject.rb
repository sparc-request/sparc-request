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
  attr_accessible :arm_edited

  accepts_nested_attributes_for :calendar

  after_create { self.create_calendar }

  def label
    label = nil

    if not external_subject_id.blank?
      label = "Subject ID:#{external_subject_id}"
    end
    
    if not mrn.blank?
      label = "Subject MRN:#{mrn}"
    end

    label
  end

  def has_appointments?
    !self.calendar.appointments.empty?
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
