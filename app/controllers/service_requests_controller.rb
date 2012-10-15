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
    if session[:saved_study_id]
      @service_request.protocol = Study.find session[:saved_study_id]
      session.delete :saved_study_id
    elsif session[:saved_project_id]
      @service_request.protocol = Project.find session[:saved_project_id]
      session.delete :saved_project_id
    end
  end
  
  def service_details
    @service_request = ServiceRequest.find session[:service_request_id]
  end

  def service_calendar
    #use session so we know what page to show when tabs are switched
    session[:service_calendar_page] = params[:page] if params[:page]

    @service_request = ServiceRequest.find session[:service_request_id]

    # build out visits if they don't already exist and delete/create if the visit count changes
    @service_request.line_items.where("is_one_time_fee is not true").each do |line_item|
      unless line_item.visits.count == @service_request.visit_count
        if line_item.visits.count < @service_request.visit_count
          (@service_request.visit_count - line_item.visits.count).times do
            line_item.visits.create
          end
        elsif line_item.visits.count > @service_request.visit_count
          (line_item.visits.count - @service_request.visit_count).times do
            line_item.visits.last.delete
          end
        end
      end
    end
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
      @service_request.line_items.create(:service_id => service.id, :optional => true, :is_one_time_fee => service.displayed_pricing_map.is_one_time_fee)

      # add required services to line items
      service.required_services.each do |rs|
        @service_request.line_items.create(:service_id => rs.id, :optional => false, :is_one_time_fee => rs.displayed_pricing_map.is_one_time_fee)
      end

      # add optional services to line items
      service.optional_services.each do |rs|
        @service_request.line_items.create(:service_id => rs.id, :optional => true, :is_one_time_fee => rs.displayed_pricing_map.is_one_time_fee)
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
