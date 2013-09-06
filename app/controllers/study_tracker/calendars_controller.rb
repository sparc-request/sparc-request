class StudyTracker::CalendarsController < StudyTracker::BaseController
  before_filter :check_work_fulfillment_status, :except => [:add_note, :add_service]

  def show
    @calendar = Calendar.find(params[:id])
    get_calendar_data(@calendar)
  end

  def add_note
    @appointment = Appointment.find(params[:appointment_id])
    if @appointment.notes.create(:identity_id => @user.id, :body => params[:body])
      @appointment.reload
      render :partial => 'study_tracker/calendars/notes', :locals => {:appointment => @appointment}
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@appointment.errors) }
      end
    end
  end

  def add_service
    appointment = Appointment.find(params[:appointment_id])
    @procedure = appointment.procedures.new(:service_id => params[:service_id])
    render :partial => 'new_procedure', :locals => {:appointment_index => params[:appointment_index], :procedure_index => params[:procedure_index]}
  end

  private
  def check_work_fulfillment_status
    @sub_service_request ||= SubServiceRequest.find(params[:sub_service_request_id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end
  end
  def get_calendar_data(calendar)
    # Get the cores
    @nutrition = Organization.tagged_with("nutrition").first
    @nursing   = Organization.tagged_with("nursing").first
    @lab       = Organization.tagged_with("laboratory").first
    @imaging   = Organization.tagged_with("imaging").first

    @subject = calendar.subject
    @appointments = calendar.appointments.includes(:visit_group).sort{|x,y| x.visit_group.position <=> y.visit_group.position }

    @uncompleted_appointments = @appointments.reject{|x| x.completed_at? }
    @completed_appointments = @appointments.select{|x| x.completed_at? }
    @default_appointment = @uncompleted_appointments.first || @appointments.first
    @default_core = (cookies['current_core'] ? Organization.find(cookies['current_core']) : @nursing)
    default_procedures = @default_appointment.procedures.select{|x| x.core == @nursing}
    @default_subtotal = @default_appointment.completed_at ? default_procedures.sum{|x| x.total} : 0.00
  end
end
