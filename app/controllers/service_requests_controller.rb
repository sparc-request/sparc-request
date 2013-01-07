class ServiceRequestsController < ApplicationController
  before_filter :initialize_service_request, :except => [:approve_changes]
  before_filter :authorize_identity, :except => [:approve_changes]
  before_filter :authenticate_identity!, :except => [:catalog, :add_service, :remove_service, :ask_a_question]
  layout false, :only => :ask_a_question

  def show
    @protocol = @service_request.protocol
    @service_list = @service_request.service_list

    # TODO: this gives an error in the spec tests, because they think
    # it's trying to render html instead of xlsx
    #
    #   render xlsx: "show", filename: "service_request_#{@service_request.id}", disposition: "inline"
    #
    # So I did this instead, but I don't know if it's right:
    #
    respond_to do |format|
      format.xlsx do
        render xlsx: "show", filename: "service_request_#{@service_request.id}", disposition: "inline"
      end
    end
  end

  def navigate
    errors = [] 
    # need to save and navigate to the right page

    #### add logic to save data
    referrer = request.referrer.split('/').last
    
    #### convert dollars to cents for subsidy
    if params[:service_request] && params[:service_request][:sub_service_requests_attributes]
      params[:service_request][:sub_service_requests_attributes].each do |key, values|
        dollars = values[:subsidy_attributes][:pi_contribution]

        if dollars.blank? # we don't want to create a subsidy if it's blank
          values.delete(:subsidy_attributes) 
          ssr = @service_request.sub_service_requests.find values[:id]
          ssr.subsidy.delete if ssr.subsidy
        else
          values[:subsidy_attributes][:pi_contribution] = Service.dollars_to_cents(dollars)
        end
      end
    end

    @service_request.update_attributes(params[:service_request])

    #### save/update documents if we have them
    process_ssr_organization_ids = params[:process_ssr_organization_ids]
    document_grouping_id = params[:document_grouping_id]
    document = params[:document]

    if document_grouping_id and not process_ssr_organization_ids
      # we are deleting this grouping, this is essentially the same as clicking delete next to a grouping
      document_grouping = @service_request.document_groupings.find document_grouping_id
      document_grouping.destroy
    elsif process_ssr_organization_ids and (!document or params[:doc_type].empty?) and not document_grouping_id # new document but we didn't provide either the document or document type
      # we did not provide a document
      #[{:visit_count=>["You must specify the estimated total number of visits (greater than zero) before continuing."], :subject_count=>["You must specify the estimated total number of subjects before continuing."]}]
      doc_errors = {}
      doc_errors[:document] = ["You must select a document to upload"] if !document
      doc_errors[:doc_type] = ["You must provide a document type"] if params[:doc_type].empty?
      errors << doc_errors
    elsif process_ssr_organization_ids and not document_grouping_id
      # we have a new grouping
      document_grouping = @service_request.document_groupings.create
      process_ssr_organization_ids.each do |org_id|
        sub_service_request = @service_request.sub_service_requests.find_by_organization_id org_id.to_i
        sub_service_request.documents.create :document => document, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other], :document_grouping_id => document_grouping.id
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

        document_grouping.reload
        document_grouping.destroy if document_grouping.documents.empty?
      end
      
      to_add.each do |org_id|
        if document and not params[:doc_type].empty?
          sub_service_request = @service_request.sub_service_requests.find_or_create_by_organization_id :organization_id => org_id.to_i
          sub_service_request.documents.create :document => document, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other], :document_grouping_id => document_grouping.id
          sub_service_request.save
        else
          doc_errors = {}
          doc_errors[:document] = ["You must select a document to upload"] if !document
          doc_errors[:doc_type] = ["You must provide a document type"] if params[:doc_type].empty?
          errors << doc_errors
        end
      end

      # updating sub_service_request documents should create a new grouping unless the grouping only contains documents for that sub_service_request
      to_update.each do |org_id|
        if params[:doc_type].empty?
          errors << {:document_upload => ["You must provide a document type"]}
        else
          if @sub_service_request.nil? or document_grouping.documents.size == 1 # we either don't have a sub_service_request or the only document in this group is the one we are updating
            document_grouping.documents.each do |doc|
              new_doc = document ? document : doc.document # use the old document
              doc.update_attributes(:document => new_doc, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other]) if doc.organization.id == org_id.to_i
            end
          else # we have a sub_service_request and the document count is greater than 1 so we need to do some special stuff
            new_document_grouping = @service_request.document_groupings.create
            document_grouping.documents.each do |doc|
              new_doc = document ? document : doc.document # use the old document
              doc.update_attributes({:document => new_doc, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other], :document_grouping_id => new_document_grouping.id}) if doc.organization.id == @sub_service_request.id
            end
          end
        end
      end
    end

    # end document saving stuff

    location = params["location"]
    additional_params = request.referrer.split('/').last.split('?').size == 2 ? "?" + request.referrer.split('/').last.split('?').last : nil
    validates = params["validates"]

    if (@validation_groups[location].nil? or @validation_groups[location].map{|vg| @service_request.group_valid? vg.to_sym}.all?) and (validates.blank? or @service_request.group_valid? validates.to_sym) and errors.empty?
      @service_request.save(:validate => false)
      redirect_to "/service_requests/#{@service_request.id}/#{location}#{additional_params}"
    else
      if @validation_groups[location]
        @validation_groups[location].each do |vg| 
          errors << @service_request.grouped_errors[vg.to_sym].messages unless @service_request.grouped_errors[vg.to_sym].messages.empty?
        end
      end

      unless validates.blank?
        errors << @service_request.grouped_errors[validates.to_sym].messages unless @service_request.grouped_errors[validates.to_sym].empty?
      end

      session[:errors] = errors.compact.flatten.first # TODO I DON'T LIKE THIS AT ALL
      redirect_to :back
    end
  end

  # service request wizard pages

  def catalog
    if session['sub_service_request_id']
      @institutions = @sub_service_request.organization.parents.select{|x| x.type == 'Institution'}
    else
      @institutions = Institution.order('`order`')
    end
  end
  
  def protocol
    @service_request.update_attribute(:service_requester_id, current_user.id) if @service_request.service_requester_id.nil?
    
    @studies = @sub_service_request.nil? ? current_user.studies : [@service_request.protocol]
    @projects = @sub_service_request.nil? ? current_user.projects : [@service_request.protocol]
    
    if session[:saved_study_id]
      @service_request.protocol = Study.find session[:saved_study_id]
      session.delete :saved_study_id
    elsif session[:saved_project_id]
      @service_request.protocol = Project.find session[:saved_project_id]
      session.delete :saved_project_id
    end
  end
  
  def service_details
  end

  def service_calendar
    #use session so we know what page to show when tabs are switched
    session[:service_calendar_page] = params[:page] if params[:page]

    # TODO: why is @page not set here?  if it's not supposed to be set
    # then there should be a comment as to why it's set in #review but
    # not here

    # build out visits if they don't already exist and delete/create if the visit count changes
    @service_request.per_patient_per_visit_line_items.each do |line_item|
      if line_item.subject_count.nil?
        line_item.update_attribute(:subject_count, @service_request.subject_count)
      end

      # TODO: refactor this into the model
      unless line_item.visits.count == @service_request.visit_count
        ActiveRecord::Base.transaction do
          if line_item.visits.count < @service_request.visit_count
            n = @service_request.visit_count - line_item.visits.count
            Visit.bulk_create(n, :line_item_id => line_item.id)
          elsif line_item.visits.count > @service_request.visit_count
            line_item.visits.last(line_item.visits.count - @service_request.visit_count).each do |li|
              li.delete
            end
          end
        end
      end
    end
  end

  def service_subsidy
    @subsidies = []
    @service_request.sub_service_requests.each do |ssr|
      if ssr.subsidy
        # we already have a subsidy; add it to the list
        @subsidies << ssr.subsidy
      elsif ssr.eligible_for_subsidy?
        # we don't have a subsidy yet; add it to the list but don't save
        # it yet
        # TODO: is it a good idea to modify this SubServiceRequest like
        # this without saving it to the database?
        ssr.build_subsidy
        @subsidies << ssr.subsidy
      end
    end
  end
  
  def document_management
    @service_list = @service_request.service_list
  end
  
  def review
    session[:service_calendar_page] = params[:page] if params[:page]

    @service_list = @service_request.service_list
    @protocol = @service_request.protocol
    
    @page = @service_request.set_visit_page session[:service_calendar_page].to_i
    @tab = 'pricing'
  end

  def confirmation
    # TODO: refactor into the ServiceRequest model
    @service_request.update_attribute(:status, 'submitted')
    @service_request.update_attribute(:submitted_at, Time.now)
    next_ssr_id = @service_request.protocol.next_ssr_id || 1
    @service_request.sub_service_requests.each do |ssr|
      ssr.update_attribute(:status, 'submitted')
      ssr.update_attribute(:ssr_id, "%04d" % next_ssr_id) unless ssr.ssr_id
      next_ssr_id += 1
    end
    
    @protocol = @service_request.protocol
    @service_list = @service_request.service_list

    @protocol.update_attribute(:next_ssr_id, next_ssr_id)

    # Does an approval need to be created, check that the user submitting has approve rights
    if @protocol.project_roles.detect{|pr| pr.identity_id == current_user.id}.project_rights != "approve"
      approval = @service_request.approvals.create
    else
      approval = false
    end

    # generate the excel for this service request
    xls = render_to_string :action => 'show', :formats => [:xlsx]

    # send e-mail to all folks with view and above
    @protocol.project_roles.each do |project_role|
      next if project_role.project_rights == 'none'
      Notifier.notify_user(project_role, @service_request, xls, approval).deliver
    end

    # send e-mail to admins and service providers
    Notifier.notify_admin(@service_request, xls).deliver

    # send e-mail to all service providers
    if @sub_service_request # only notify the service providers for this sub service request
      @sub_service_request.organization.service_providers.where(ServiceProvider.arel_table[:hold_emails].not_eq(true)).each do |service_provider|
        Notifier.notify_service_provider(service_provider, @service_request, xls).deliver
      end
    else
      @service_request.sub_service_requests.each do |sub_service_request|
        sub_service_request.organization.service_providers.where(ServiceProvider.arel_table[:hold_emails].not_eq(true)).each do |service_provider|
          Notifier.notify_service_provider(service_provider, @service_request, xls).deliver
        end
      end
    end
    
    render :formats => [:html]
  end

  def approve_changes
    @approval = @service_request.approvals.where(:id => params[:approval_id]).first
    @previously_approved = true
 
    if @approval and @approval.identity.nil?
      @approval.update_attribute(:identity_id, current_user.id)
      @previously_approved = false 
    end
  end

  def save_and_exit
    # TODO: refactor into the ServiceRequest model

    @service_request.update_attribute(:status, 'draft')
    
    next_ssr_id = @service_request.protocol.next_ssr_id || 1
    @service_request.sub_service_requests.each do |ssr|
      ssr.update_attribute(:status, 'draft')
      ssr.update_attribute(:ssr_id, "%04d" % next_ssr_id) unless ssr.ssr_id
      next_ssr_id += 1
    end
    @service_request.protocol.update_attribute(:next_ssr_id, next_ssr_id)

    redirect_to USER_PORTAL_LINK 
  end

  def refresh_service_calendar
    session[:service_calendar_page] = params[:page] if params[:page]
    @page = @service_request.set_visit_page session[:service_calendar_page].to_i
    @tab = 'pricing'
  end


  # methods only used by ajax requests

  def add_service
    id = params[:service_id].sub('service-', '').to_i
    if @service_request.line_items.map(&:service_id).include? id
      render :text => 'Service exists in line items' 
    else
      service = Service.find id

      # add service to line items
      @service_request.line_items.create(:service_id => service.id, :optional => true, :quantity => service.displayed_pricing_map.unit_minimum)

      # add required services to line items
      service.required_services.each do |rs|
        @service_request.line_items.create(:service_id => rs.id, :optional => false, :quantity => service.displayed_pricing_map.unit_minimum)
      end

      # add optional services to line items
      service.optional_services.each do |rs|
        @service_request.line_items.create(:service_id => rs.id, :optional => true, :quantity => service.displayed_pricing_map.unit_minimum)
      end

      # create sub_service_rquests
      @service_request.reload
      @service_request.service_list.each do |org_id, values|
        line_items = values[:line_items]
        ssr = @service_request.sub_service_requests.find_or_create_by_organization_id :organization_id => org_id.to_i
        unless @service_request.status.nil? and !ssr.status.nil?
          ssr.update_attribute(:status, @service_request.status)
        end

        line_items.each do |li|
          li.update_attribute(:sub_service_request_id, ssr.id)
        end
      end
    end
  end

  def remove_service
    id = params[:line_item_id].sub('line_item-', '').to_i

    service = @service_request.line_items.find(id).service
    line_item_service_ids = @service_request.line_items.map(&:service_id)

    # look at related services and set them to optional
    # TODO POTENTIAL ISSUE: what if another service has the same related service
    service.related_services.each do |rs|
      if line_item_service_ids.include? rs.id
        @service_request.line_items.find_by_service_id(rs.id).update_attribute(:optional, true)
      end
    end

    @line_items.find_by_service_id(service.id).delete
    @line_items.reload
    
    #@service_request = current_user.service_requests.find session[:service_request_id]
    @service_request = ServiceRequest.find session[:service_request_id]
    @page = request.referrer.split('/').last # we need for pages other than the catalog

    # clean up sub_service_requests
    @service_request.reload
    to_delete = @service_request.sub_service_requests.map(&:organization_id) - @service_request.service_list.keys
    to_delete.each do |org_id|
      @service_request.sub_service_requests.find_by_organization_id(org_id).destroy
    end
  end

  def delete_documents
    # deletes a group of documents unless we are working with a sub_service_request
    grouping = @service_request.document_groupings.find params[:document_group_id]
    @tr_id = "#document_grouping_#{grouping.id}"

    if @sub_service_request.nil?
      grouping.destroy # destroys the grouping and the documents
    else
      grouping.documents.find_by_sub_service_request_id(@sub_service_request.id).destroy
      grouping.reload
      grouping.destroy if grouping.documents.empty?
    end
  end

  def edit_documents
    @grouping = @service_request.document_groupings.find params[:document_group_id]
    @service_list = @service_request.service_list
  end

  def ask_a_question
    from = params['question_email'] || 'no-reply@musc.edu'
    body = params['question_body'] || 'No question asked'

    question = Question.create :to => DEFAULT_MAIL_TO, :from => from, :body => body
    Notifier.ask_a_question(question).deliver
  end

  def select_calendar_row
    @line_item = LineItem.find params[:line_item_id]
    @line_item.visits.each do |visit|
      visit.update_attributes(
          quantity:              visit.line_item.service.displayed_pricing_map.unit_minimum,
          research_billing_qty:  visit.line_item.service.displayed_pricing_map.unit_minimum,
          insurance_billing_qty: 0,
          effort_billing_qty:    0)
    end
    
    render :partial => 'update_service_calendar'
  end
  
  def unselect_calendar_row
    @line_item = LineItem.find params[:line_item_id]
    @line_item.visits.each do |visit|
      visit.update_attributes({:quantity => 0, :research_billing_qty => 0, :insurance_billing_qty => 0, :effort_billing_qty => 0})
    end

    render :partial => 'update_service_calendar'
  end

  def select_calendar_column
    column_id = params[:column_id].to_i

    @service_request.per_patient_per_visit_line_items.each do |line_item|
      visit = line_item.visits[column_id - 1] # columns start with 1 but visits array positions start at 0
      visit.update_attributes(
          quantity:              visit.line_item.service.displayed_pricing_map.unit_minimum,
          research_billing_qty:  visit.line_item.service.displayed_pricing_map.unit_minimum,
          insurance_billing_qty: 0,
          effort_billing_qty:    0)
    end
    
    render :partial => 'update_service_calendar'
  end
  
  def unselect_calendar_column
    column_id = params[:column_id].to_i

    @service_request.per_patient_per_visit_line_items.each do |line_item|
      visit = line_item.visits[column_id - 1] # columns start with 1 but visits array positions start at 0
      visit.update_attributes({:quantity => 0, :research_billing_qty => 0, :insurance_billing_qty => 0, :effort_billing_qty => 0})
    end
    
    render :partial => 'update_service_calendar'
  end
end
