class StudyTracker::SubServiceRequestsController < StudyTracker::BaseController
  respond_to :js, :html
  before_filter :check_work_fulfillment_status

  def show
    # TODO it might be nice to move these into a separate method so that
    # other methods (notably, update) can load up the necesary instance
    # methods without having to call #show, in case we add unintended
    # side-effects to #show

    session[:sub_service_request_id] = @sub_service_request.id
    session[:service_request_id] = @sub_service_request.service_request_id
    session[:service_calendar_pages] = params[:pages] if params[:pages]

    @service_request = @sub_service_request.service_request
    @protocol = @sub_service_request.try(:service_request).try(:protocol)
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}

    @selected_arm = @service_request.arms.first

    @study_tracker = true

    # "Preload" the intial view of the payments tab with a blank form row
    @sub_service_request.payments.build if @sub_service_request.payments.blank?
  end

  def service_calendar
    @service_request = @sub_service_request.service_request
  end

  def update
    if @sub_service_request.update_attributes(params[:sub_service_request])
      respond_to do |format|
        format.js { render :js => "$('.routing_message').removeClass('uncheck').addClass('check')" }
        format.html { redirect_to study_tracker_sub_service_request_path(@sub_service_request) }
      end
    else
      respond_to do |format|
        format.js { render :js => "$('.routing_message').removeClass('check').addClass('uncheck')" }
        format.html do
          # handle errors
          show
          render :show
        end
      end
    end
  end

  private
  def check_work_fulfillment_status
    @sub_service_request ||= SubServiceRequest.find(params[:id])
    unless @sub_service_request.in_work_fulfillment?
      redirect_to root_path
    end
  end
end
