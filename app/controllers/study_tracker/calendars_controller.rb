class StudyTracker::CalendarsController < StudyTracker::BaseController
  before_filter :check_work_fulfillment_status

  def show
    # Get the cores
    @nutrition = Organization.tagged_with("nutrition").first
    @nursing   = Organization.tagged_with("nursing").first
    @lab       = Organization.tagged_with("laboratory").first
    @imaging   = Organization.tagged_with("imaging").first

    @calendar = Calendar.find(params[:id])
    @subject = @calendar.subject
    @appointments = @calendar.appointments.includes(:visit_group).sort{|x,y| x.visit_group.position <=> y.visit_group.position }

    @uncompleted_appointments = @appointments.reject{|x| x.completed_at? }
    @default_appointment = @uncompleted_appointments.first || @appointments.first
    default_procedures = @default_appointment.procedures.select{|x| x.line_item.service.organization == @nutrition}
    @default_subtotal = default_procedures.sum{|x| x.total}

    
  end

  private
  def check_work_fulfillment_status
    @sub_service_request ||= SubServiceRequest.find(params[:sub_service_request_id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end
  end
end
