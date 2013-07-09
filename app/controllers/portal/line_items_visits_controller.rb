class Portal::LineItemsVisitsController < Portal::BaseController
  respond_to :json, :js, :html

  def update_from_fulfillment
    @line_items_visit = LineItemsVisit.find(params[:id])
    @sub_service_request = @line_items_visit.line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @selected_arm = @service_request.arms.first
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @study_tracker = params[:study_tracker] == "true"

    if @line_items_visit.update_attributes(params[:line_items_visit])
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
      render 'portal/sub_service_requests/add_line_item'
    else
      @line_items_visit.reload
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@line_items_visit.errors) } 
      end
    end
  end

  def destroy
    @line_items_visit = LineItemsVisit.find(params[:id])
    @sub_service_request = @line_items_visit.line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @selected_arm = @service_request.arms.first
    line_item = @line_items_visit.line_item
    @study_tracker = params[:study_tracker] == "true"

    ActiveRecord::Base.transaction do
      @line_items_visit.remove_procedures
      if @line_items_visit.destroy
        line_item.destroy unless line_item.line_items_visits.count > 0
        # Have to reload the service request to get the correct direct cost total for the subsidy
        @subsidy.try(:sub_service_request).try(:reload)
        @subsidy.try(:fix_pi_contribution, percent)
        @service_request = @sub_service_request.service_request
        @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
        @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
        render 'portal/sub_service_requests/add_line_item'
      end
    end
  end
end
