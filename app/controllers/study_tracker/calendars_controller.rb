class StudyTracker::CalendarsController < StudyTracker::BaseController
  before_filter :check_work_fulfillment_status

  def show
    @calendar = Calendar.find(params[:id])
    @subject = @calendar.subject
    @appointments = @calendar.appointments.includes(:visit_group).sort{|x,y| x.visit_group.position <=> y.visit_group.position }

    @uncompleted_appointments = @appointments.reject{|x| x.completed_at? }
    @default_appointment = @uncompleted_appointments.first || @appointments.first
    default_procedures = @default_appointment.procedures.reject{|x| !x.line_item.service.organization_id == 17}
    @default_subtotal = default_procedures.sum{|x| x.line_item.per_unit_cost}
  end

  private
  def check_work_fulfillment_status
    @sub_service_request ||= SubServiceRequest.find(params[:sub_service_request_id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end
  end
end
