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
    @protocol = Protocol.includes(:subjects).find(@service_request.protocol_id)
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}

    @line_items = LineItem.where(:sub_service_request_id => @sub_service_request.id)

    @selected_arm = @service_request.arms.first

    @study_tracker = true

    # "Preload" the intial view of the payments tab with a blank form row
    @sub_service_request.payments.build if @sub_service_request.payments.blank?

    # get cwf organizations
    @cwf_organizations = Organization.get_cwf_organizations

    # min start date and max end date
    cwf_audit = @sub_service_request.audits.where(:audited_changes => YAML.dump({"in_work_fulfillment" => [nil, true]})).first
    @min_start_date = cwf_audit.nil? ? "N/A" : cwf_audit.created_at.utc
    @max_end_date = Time.now.utc
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
