module StudyTracker::ServiceRequestsHelper
  def appointment_visits appointments
    options_array = appointments.map{|x| ["##{x.position_switch}: #{x.name_switch}", {'data-appointment_id'=>x.id}]}
    #options_array.unshift(["Dashboard", {'data-appointment_id' => "dashboard"}])
  end
end
