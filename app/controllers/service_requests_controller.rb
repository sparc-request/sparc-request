class ServiceRequestsController < ApplicationController
  def navigate
    # need to save and navigate to the right page
    puts "#"*50
    puts params.inspect
    puts request.referrer.split('/').last
    puts params[:service_request]
    puts "#"*50

    #### add logic to save data
    referrer = request.referrer.split('/').last
    @service_request = ServiceRequest.find session[:service_request_id]
    @service_request.update_attributes(params[:service_request])
    location = params["location"]

    if @validation_groups[location].nil? or @validation_groups[location].map{|vg| @service_request.group_valid? vg.to_sym}.all?
      redirect_to "/service_requests/#{@service_request.id}/#{location}"
    else
      session[:errors] = @validation_groups[location].map{|vg| @service_request.grouped_errors[vg.to_sym]}
      redirect_to :back
    end
  end

  # service request wizard pages

  def catalog
    @institutions = Institution.all
    #@service_request = @current_user.service_requests.find session[:service_request_id]
    @service_request = ServiceRequest.find session[:service_request_id]
  end
  
  def protocol
    @studies = @current_user.studies
    @projects = @current_user.projects
    @service_request = ServiceRequest.find session[:service_request_id]
  end
  
  def service_details
    @service_request = ServiceRequest.find session[:service_request_id]
  end

  # methods only used by ajax requests

  def add_service
    id = params[:service_id].sub('service-', '').to_i
    #@service_request = @current_user.service_requests.find session[:service_request_id]
    @service_request = ServiceRequest.find session[:service_request_id]
    if @service_request.line_items.map(&:service_id).include? id
      render :text => 'Service exists in line items' 
    else
      service = Service.find id

      # add service to line items
      @service_request.line_items.create(:service_id => service.id, :optional => true)

      # add required services to line items
      service.required_services.each do |rs|
        @service_request.line_items.create(:service_id => rs.id, :optional => false)
      end

      # add optional services to line items
      service.optional_services.each do |rs|
        @service_request.line_items.create(:service_id => rs.id, :optional => true)
      end
    end
  end

  def remove_service
    id = params[:line_item_id].sub('line_item-', '').to_i
    #@service_request = @current_user.service_requests.find session[:service_request_id]
    @service_request = ServiceRequest.find session[:service_request_id]

    line_items = @service_request.line_items
    service = line_items.find(id).service
    line_item_service_ids = line_items.map(&:service_id)

    # look at related services and set them to optional
    # POTENTIAL ISSUE: what if another service has the same related service
    service.related_services.each do |rs|
      if line_item_service_ids.include? rs.id
        line_items.find_by_service_id(rs.id).update_attribute(:optional, true)
      end
    end

    @service_request.line_items.find_by_service_id(service.id).delete
    
    #@service_request = @current_user.service_requests.find session[:service_request_id]
    @service_request = ServiceRequest.find session[:service_request_id]
    @page = request.referrer.split('/').last # we need for pages other than the catalog
  end
end
