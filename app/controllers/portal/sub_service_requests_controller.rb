class Portal::SubServiceRequestsController < Portal::BaseController
  respond_to :json, :js, :html

  def show
    @sub_service_request = SubServiceRequest.find(params[:id])

    session[:sub_service_request_id] = @sub_service_request.id
    session[:service_request_id] = @sub_service_request.service_request_id
    session[:service_calendar_pages] = params[:pages] if params[:pages]

    if @user.can_edit_fulfillment? @sub_service_request.organization
      @user_toasts = @user.received_toast_messages.select {|x| x.sending_object.class == SubServiceRequest}.select {|y| y.sending_class_id == @sub_service_request.id}
      @service_request = @sub_service_request.service_request
      @protocol = @sub_service_request.try(:service_request).try(:protocol)
      if not @protocol then
        raise ArgumentError, "Sub service request does not have a protocol; is it an invalid sub service request?"
      end
      @protocol.populate_for_edit if @protocol.type == "Study"
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.is_one_time_fee?}
      @subsidy = @sub_service_request.subsidy
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      @service_list = @service_request.service_list
      @related_service_requests = @protocol.all_child_sub_service_requests
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      @selected_arm = @service_request.arms.first
    else
      redirect_to portal_admin_index_path
    end
  end

  def update_from_fulfillment
    @sub_service_request = SubServiceRequest.find(params[:id])
    @study_tracker = params[:study_tracker] == "true"
    saved_status = @sub_service_request.status

    if @sub_service_request.update_attributes(params[:sub_service_request])
      @sub_service_request.generate_approvals(@user)
      @sub_service_request.distribute_surveys if @sub_service_request.status == 'complete' and @sub_service_request.status != saved_status #status is complete and it was something different before
      @service_request = @sub_service_request.service_request
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      render 'portal/sub_service_requests/update_past_status'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@sub_service_request.errors) }
      end
    end
  end

  def update_from_project_study_information
    @protocol = Protocol.find(params[:protocol_id])
    @sub_service_request = SubServiceRequest.find params[:id]

    attrs = params[@protocol.type.downcase.to_sym]
    
    if @protocol.update_attributes attrs
      redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
    else
      @user_toasts = @user.received_toast_messages.select {|x| x.sending_object.class == SubServiceRequest}
      @service_request = @sub_service_request.service_request
      @protocol.populate_for_edit if @protocol.type == "Study"
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.is_one_time_fee?}
      @subsidy = @sub_service_request.subsidy
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      @service_list = @service_request.service_list
      @related_service_requests = @protocol.all_child_sub_service_requests
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      @selected_arm = @service_request.arms.first
      render :action => 'show'
    end
  end   

  def add_note
    @sub_service_request = SubServiceRequest.find(params[:id])
    if @sub_service_request.notes.create(:identity_id => @user.id, :body => params[:body])
      @sub_service_request.reload
      render 'portal/sub_service_requests/add_note'
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@sub_service_request.errors) }
      end
    end
  end

  def add_line_item
    @sub_service_request = SubServiceRequest.find(params[:id])
    @service_request = @sub_service_request.service_request
    @subsidy = @sub_service_request.subsidy
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.is_one_time_fee?}
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.is_one_time_fee?}
    @arm_id = params[:arm_id].to_i if params[:arm_id]
    @selected_arm = params[:arm_id] ? Arm.find(@arm_id) : @service_request.arms.first
    service = Service.find(params[:new_service_id])
    @study_tracker = params[:study_tracker] == "true"
    
    if @sub_service_request.create_line_item(
        service_id: params[:new_service_id],
        sub_service_request_id: params[:sub_service_request_id])
      # Have to reload the service request to get the correct direct cost total for the subsidy
      @subsidy.try(:sub_service_request).try(:reload)
      @subsidy.try(:fix_pi_contribution, percent)
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@sub_service_request.errors) }
      end
    end
  end

  def new_document
    errors = []
    #### add logic to save data
    referrer = request.referrer.split('/').last
    @sub_service_request = SubServiceRequest.find(params[:id])
    @service_request = @sub_service_request.service_request
    @service_request.update_attributes(params[:service_request])

    #### save/update documents if we have them
    process_ssr_organization_ids = params[:process_ssr_organization_ids]
    document_grouping_id = params[:document_grouping_id]
    document = params[:document]

    if document_grouping_id and not process_ssr_organization_ids
      # we are deleting this grouping, this is essentially the same as clicking delete next to a grouping
      document_grouping = @service_request.document_groupings.find document_grouping_id
      document_grouping.destroy
    elsif process_ssr_organization_ids and (not document or params[:doc_type] == "") and not document_grouping_id
      # we did not provide a document
      errors << "You must select a document to upload" if not document
      # we did not provide a document type
      errors << "You must select a document type" if params[:doc_type] == ""
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
      end
      
      to_add.each do |org_id|
        sub_service_request = @service_request.sub_service_requests.find_or_create_by_organization_id :organization_id => org_id.to_i
        sub_service_request.documents.create :document => document, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other], :document_grouping_id => document_grouping.id
        sub_service_request.save
      end
      to_update.each do |org_id|
        if document_grouping.documents.size == 1# updating sub_service_request documents should create a new grouping unless the grouping only contains documents for that sub_service_request
          document_grouping.documents.each do |doc|
            if params[:is_edit] && !document
              doc.update_attributes(:doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other]) if doc.organization.id == org_id.to_i
            else
              doc.update_attributes(:document => document, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other]) if doc.organization.id == org_id.to_i
            end
          end
        else# The document count is greater than 1 so we need to do some special stuff
          new_document_grouping = @service_request.document_groupings.create
          document_grouping.documents.each do |doc|
            doc.update_attribute(:document_grouping_id, new_document_grouping.id) if doc.organization.id == @sub_service_request.id
          end
        end
      end
    end

    if errors
      session[:errors] = errors # TODO I DON'T LIKE THIS AT ALL
      redirect_to :back
    else
      session.delete(:errors)
      @service_request.save(:validate => false)
      redirect_to "/portal/admin/sub_service_requests/#{@sub_service_request.id}"
    end

  end

  def delete_documents
    # deletes a group of documents
    sub_service_request = SubServiceRequest.find(params[:id])
    service_request = sub_service_request.service_request
    grouping = service_request.document_groupings.find params[:document_group_id]
    @tr_id = "#document_grouping_#{grouping.id}"

    grouping.documents.find_by_sub_service_request_id(sub_service_request.id).destroy
    grouping.reload
    grouping.destroy if grouping.documents.empty?
  end

  def edit_documents
    @sub_service_request = SubServiceRequest.find(params[:id])
    service_request = @sub_service_request.service_request
    @grouping = service_request.document_groupings.find params[:document_group_id]
    @service_list = service_request.service_list
  end

  def destroy
    @sub_service_request = SubServiceRequest.find(params[:id])
    if @sub_service_request.destroy
      # Delete all related toast messages
      ToastMessage.where(:sending_class_id => params[:id]).where(:sending_class => "SubServiceRequest").each do |toast|
        toast.destroy
      end

      # notify users with view rights or above of deletion
      @sub_service_request.service_request.protocol.project_roles.each do |project_role|
        next if project_role.project_rights == 'none'
        Notifier.sub_service_request_deleted(project_role.identity, @sub_service_request).deliver unless project_role.identity.email.blank?
      end

      # notify service providers
      @sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
        Notifier.sub_service_request_deleted(service_provider.identity, @sub_service_request).deliver
      end
    end

    redirect_to "/portal/admin"
  end

end
