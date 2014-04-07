class Portal::FulfillmentsController < Portal::BaseController
  respond_to :js, :json, :html

  def update_from_fulfillment
    @fulfillment = Fulfillment.find(params[:id])
    if @fulfillment.update_attributes(params[:fulfillment])
      render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@fulfillment.errors) } 
      end
    end
  end

  def create
    if @fulfillment = Fulfillment.create(params[:fulfillment])
      @sub_service_request = @fulfillment.line_item.sub_service_request
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      @active = @fulfillment.line_item.id
      @fulfillment.update_attributes(fulfilled_r_quantity: 1, requested_r_quantity: @fulfillment.line_item.quantity)
      render 'create'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@fulfillment.errors) } 
      end
    end
  end

  def destroy
    @fulfillment = Fulfillment.find(params[:id])
    @sub_service_request = @fulfillment.line_item.sub_service_request
    if @fulfillment.delete
      @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
      render 'create'
    end
  end
end
