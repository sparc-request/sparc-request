class Portal::SubsidiesController < Portal::BaseController
  respond_to :json, :js, :html

  def update_from_fulfillment
    @subsidy = Subsidy.find(params[:id])
    # Fix pi_contribution to be in cents
    data = params[:subsidy]
    if params[:percent_subsidy]
      total = @subsidy.sub_service_request.direct_cost_total
      subsidy = (params[:percent_subsidy].to_f / 100.0) * total
      data[:pi_contribution] = (total - subsidy) / 100
    end

    data[:pi_contribution] = data[:pi_contribution].to_f * 100.0
    data[:overridden] = true
    if @subsidy.update_attributes(data)
      # render :nothing => true
      @sub_service_request = @subsidy.sub_service_request
      render 'portal/sub_service_requests/add_subsidy'
    else
      respond_to do |format|
        format.json { render :status => 500, :json => clean_errors(@subsidy.errors) } 
      end
    end
  end

  def create
    if @subsidy = Subsidy.create(params[:subsidy])
      @sub_service_request = @subsidy.sub_service_request
      @subsidy.update_attribute(:pi_contribution, @sub_service_request.direct_cost_total)
      render 'portal/sub_service_requests/add_subsidy'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@subsidy.errors) } 
      end
    end
  end

  def destroy
    @subsidy = Subsidy.find(params[:id])
    @sub_service_request = @subsidy.sub_service_request
    if @subsidy.delete
      @subsidy = nil
      @service_request = @sub_service_request.service_request
      render 'portal/sub_service_requests/add_subsidy'
    end
  end

end
