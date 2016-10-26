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

module StudyTracker::ServiceRequestsHelper
  def appointment_visits appointments
    options_array = appointments.map{|x| ["##{x.position_switch}: #{x.name_switch}", {'data-visit_group_id' => x.try(:visit_group).try(:id)}]}.uniq
    
    options_array
  end

  def get_appointment_for_tab calendar_form, default_visit_group_id, org
    if default_visit_group_id.nil?
      appointment = calendar_form.object.appointments_for_core(org.id).detect {|x| "##{x.position_switch}: #{x.name_switch}" == @selected_key}
    else
      appointment = calendar_form.object.appointments_for_core(org.id).where(:visit_group_id => @default_visit_group_id).try(:first)
    end

    if appointment.nil?
      if default_visit_group_id
        appointment = calendar_form.object.appointments.create(:visit_group_id => default_visit_group_id, :organization_id => org.id)
      end
    end

    appointment
  end

  def display_org_tree organization
    if organization.type == "Core"
      return organization.parent.parent.try(:abbreviation) + "/" + organization.parent.try(:name) + "/" + organization.try(:name)
    elsif organization.type == "Program"
      return organization.parent.try(:abbreviation) + "/" + organization.try(:name)
    else
      return organization.try(:name)
    end
  end

  def procedures_for_visit_group appointments
    procedures = []
    if appointments
      appointments.each do |app|
        procedures << app.procedures.select{|x| x.appointment.completed_for_core?(x.core.id)}
      end
    end

    procedures.flatten
  end

  def subject_has_completed_appointment? subject
    if subject.calendar
      if !subject.calendar.appointments.reject{|x| !x.completed_at?}.empty?
        return true
      else
        return false
      end
    end
  end
end
