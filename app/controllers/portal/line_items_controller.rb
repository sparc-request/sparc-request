class Portal::LineItemsController < Portal::BaseController
  respond_to :json, :js, :html

  def update_from_fulfillment
    @line_item = LineItem.find(params[:id])
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @selected_arm = @service_request.arms.first
    @subsidy = @sub_service_request.subsidy
    @percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @study_tracker = params[:study_tracker] == "true"
    @line_items_visit = LineItemsVisit.find(params[:line_items_visit_id]) if params[:line_items_visit_id]
    @service_id = params[:service_id]

    if @line_item.service.is_one_time_fee?
      update_otf_line_item()
    else
      if update_per_patient_line_item()
        # Have to reload the service request to get the correct direct cost total for the subsidy
        @subsidy.try(:sub_service_request).try(:reload)
        @subsidy.try(:fix_pi_contribution, @percent)
        @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
        @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
        render 'portal/sub_service_requests/add_line_item'
      else
        @line_item.reload
        respond_to do |format|
          format.js { render :status => 500, :json => clean_errors(@line_item.errors) } 
        end
      end
    end
  end

  def update_from_cwf
    @line_item = LineItem.find(params[:id])
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @study_tracker = params[:study_tracker] == "true"
  
    if @line_item.update_attributes(params[:line_item])
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      render 'portal/sub_service_requests/add_otf_line_item'
    else
      @line_item.reload
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@line_item.errors) } 
      end
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    @sub_service_request = @line_item.sub_service_request
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @selected_arm = @service_request.arms.first
    @study_tracker = params[:study_tracker] == "true"
    @line_items = @sub_service_request.line_items
    was_one_time_fee = @line_item.service.is_one_time_fee?
    
    if @line_item.destroy
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:fix_pi_contribution, percent)
      @service_request = @sub_service_request.service_request
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}

      render 'portal/sub_service_requests/add_line_item'
    end
  end

  def update_per_patient_line_item
    #Create new line_item, and link up line_items_visit, modify CWF data, etc...
    @old_line_item = @line_item
    visit_ids = @line_items_visit.visits.map(&:id)
    @procedures = @old_line_item.procedures.find_all_by_visit_id(visit_ids)

    ActiveRecord::Base.transaction do
      if @line_item = LineItem.create(service_request_id: @service_request.id, service_id: @service_id, sub_service_request_id: @sub_service_request.id)

        @line_item.reload
        if @line_items_visit.update_attribute(:line_item_id, @line_item.id)
          @old_line_item.reload

          if @sub_service_request.in_work_fulfillment
            #Modify Procedures in CWF
            @procedures.each do |procedure|
              if procedure.completed?
                procedure.update_attributes(service_id: @old_line_item.service.id, line_item_id: nil)
              else
                procedure.update_attribute(:line_item_id, @line_item.id)
              end
            end
          end

          if @old_line_item.line_items_visits.empty?
            @old_line_item.destroy
          end
          return @line_item
        else
          return false
        end

      else
        return false
      end
    end
  end
end

def update_otf_line_item
  if @line_item.update_attributes(params[:line_item])
    # Have to reload the service request to get the correct direct cost total for the subsidy
    @subsidy.try(:sub_service_request).try(:reload)
    @subsidy.try(:fix_pi_contribution, @percent)
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
    render 'portal/sub_service_requests/add_line_item'
  else
    @line_item.reload
    respond_to do |format|
      format.js { render :status => 500, :json => clean_errors(@line_item.errors) }
    end
  end
end
