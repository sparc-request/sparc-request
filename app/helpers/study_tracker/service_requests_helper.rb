module StudyTracker::ServiceRequestsHelper
  def appointment_visits appointments
    options_array = appointments.map{|x| ["##{x.position_switch}: #{x.name_switch}", {'data-appointment_id'=>x.id}]}
    
    options_array
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
end
