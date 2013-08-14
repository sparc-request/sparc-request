module StudyTracker::ServiceRequestsHelper
  def appointment_visits appointments
    options_array = appointments.map{|x| ["##{x.visit_group.position}: #{x.visit_group.name}", {'data-appointment_id'=>x.id}]}
    #options_array.unshift(["Dashboard", {'data-appointment_id' => "dashboard"}])
  end
end
