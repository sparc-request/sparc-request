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
