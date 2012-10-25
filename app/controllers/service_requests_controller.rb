class ServiceRequestsController < ApplicationController
  def navigate
    errors = [] 
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

    #### save/update documents if we have them
    process_ssr_organization_ids = params[:process_ssr_organization_ids]
    document_grouping_id = params[:document_grouping_id]
    document = params[:document]

    if document_grouping_id and not process_ssr_organization_ids
      # we are deleting this grouping, this is essentially the same as clicking delete next to a grouping
      document_grouping = @service_request.document_groupings.find document_grouping_id
      document_grouping.destroy
    elsif process_ssr_organization_ids and not document and not document_grouping_id
      # we did not provide a document
      errors << {:document_upload => ["You must select a document to upload"]}
    elsif process_ssr_organization_ids and not document_grouping_id
      # we have a new grouping
      document_grouping = @service_request.document_groupings.create
      process_ssr_organization_ids.each do |org_id|
        sub_service_request = @service_request.sub_service_requests.find_or_create_by_organization_id :organization_id => org_id.to_i
        sub_service_request.documents.create :document => document, :doc_type => params[:doc_type], :document_grouping_id => document_grouping.id
        sub_service_request.save
      end
    elsif process_ssr_organization_ids and document_grouping_id
      # we need to update an existing grouping
      document_grouping = @service_request.document_groupings.find document_grouping_id
      grouping_org_ids = document_grouping.documents.map{|d| d.sub_service_request.organization_id.to_s}
      to_delete = grouping_org_ids - process_ssr_organization_ids
      to_add = process_ssr_organization_ids - grouping_org_ids
      to_update = process_ssr_organization_ids & grouping_org_ids
      to_delete.each do |org_id|
        document_grouping.documents.each do |doc|
          doc.destroy if doc.organization.id == org_id.to_i
        end
      end
      
      to_add.each do |org_id|
        sub_service_request = @service_request.sub_service_requests.find_or_create_by_organization_id :organization_id => org_id.to_i
        sub_service_request.documents.create :document => document, :doc_type => params[:doc_type], :document_grouping_id => document_grouping.id
        sub_service_request.save
      end

      to_update.each do |org_id|
        document_grouping.documents.each do |doc|
          doc.update_attributes(:document => document, :doc_type => params[:doc_type]) if doc.organization.id == org_id.to_i
        end
      end
    end

    # end document saving stuff

    location = params["location"]
    validates = params["validates"]

    if (@validation_groups[location].nil? or @validation_groups[location].map{|vg| @service_request.group_valid? vg.to_sym}.all?) and (validates.blank? or @service_request.group_valid? validates.to_sym) and errors.empty?
      @service_request.save(:validate => false)
      redirect_to "/service_requests/#{@service_request.id}/#{location}"
    else
      if @validation_groups[location]
        @validation_groups[location].each do |vg| 
          errors << @service_request.grouped_errors[vg.to_sym].messages unless @service_request.grouped_errors[vg.to_sym].messages.empty?
        end
      end

      unless validates.blank?
        errors << @service_request.grouped_errors[validates.to_sym].messages unless @service_request.grouped_errors[validates.to_sym].messages.empty?
      end
      session[:errors] = errors.compact.flatten.first # TODO I DON'T LIKE THIS AT ALL
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
    @service_request.per_patient_per_visit_line_items.each do |line_item|
      visits = line_item.visits
      unless visits.count == @service_request.visit_count
        start_time = Time.now
        ActiveRecord::Base.transaction do
          if visits.count < @service_request.visit_count then
            # Use bulk_create to optimize creation of visits
            n = @service_request.visit_count - visits.count
            Visit.bulk_create(n, :line_item_id => line_item.id)
          elsif visits.count > @service_request.visit_count
            (visits.count - @service_request.visit_count).times do
              visits.last.delete
            end
          end
        end
      end
    end
  end

  def service_subsidy
    @service_request = ServiceRequest.find session[:service_request_id]
  end
  
  def document_management
    @service_request = ServiceRequest.find session[:service_request_id]
    @service_list = @service_request.service_list
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
    # TODO POTENTIAL ISSUE: what if another service has the same related service
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

  def delete_documents
    # deletes a group of documents
    service_request = ServiceRequest.find session[:service_request_id]
    grouping = service_request.document_groupings.find params[:document_group_id]
    @tr_id = "#document_grouping_#{grouping.id}"

    grouping.destroy # destroys the grouping and the documents
  end

  def edit_documents
    service_request = ServiceRequest.find session[:service_request_id]
    @grouping = service_request.document_groupings.find params[:document_group_id]
    @service_list = service_request.service_list
  end

  def review
    @service_request = ServiceRequest.find session[:service_request_id]
    @service_list = @service_request.service_list
    @protocol = @service_request.protocol
  end

end
