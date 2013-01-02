class Portal::VisitsController < Portal::BaseController
  respond_to :json, :js, :html

  def update_from_fulfillment
    @visit = Visit.find(params[:id])
    @sub_service_request = @visit.line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    if @visit.update_attributes(params[:visit])
      # Change the pi_contribution on the subsidy in accordance with the new direct cost total
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      render 'portal/sub_service_requests/add_subsidy' # Re-render the subsidy information as total cost may be updated
      # render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@visit.errors) } 
      end
    end
  end
  
  def destroy
    @visit = Visit.find(params[:id])
    @sub_service_request = @visit.line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    position = @visit.position
    line_item = @visit.line_item
    @visit.move_to_bottom # TODO: why?
    @visit.line_item.visits.reload
    if @visit.delete
      @service_request = @sub_service_request.service_request # TODO: we already did this earlier

      # destroy all the other visits at the same position
      # TODO: this logic should be moved to the model
      @service_request.per_patient_per_visit_line_items.each do |li|
        unless li == line_item
          visit = li.visits.find_by_position(position)
          visit.try(:move_to_bottom)
          li.visits.reload
          visit.try(:delete)
        end
      end

      @service_request.update_attribute(:visit_count, @service_request.visit_count - 1)
      # Change the pi_contribution on the subsidy in accordance with the new direct cost total
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
      render 'portal/service_requests/add_per_patient_per_visit_visit'
    end
  end
end
