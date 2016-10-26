# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Portal::SubServiceRequestsController < Portal::BaseController
  respond_to :json, :js, :html

  before_filter :protocol_authorizer, :only => [:update_from_project_study_information]
      
  def show
    @sub_service_request = SubServiceRequest.find(params[:id])
    @admin = true
    session[:sub_service_request_id] = @sub_service_request.id
    session[:service_request_id] = @sub_service_request.service_request_id
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    if @user.can_edit_fulfillment? @sub_service_request.organization
      @user_toasts = @user.received_toast_messages.select {|x| x.sending_class == 'SubServiceRequest'}.select {|y| y.sending_class_id == @sub_service_request.id}
      @service_request = @sub_service_request.service_request
      @protocol = @sub_service_request.try(:service_request).try(:protocol)
      if not @protocol then
        raise ArgumentError, "Sub service request does not have a protocol; is it an invalid sub service request?"
      end
      @protocol.populate_for_edit if @protocol.type == "Study"
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.one_time_fee}
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
      @sub_service_request.update_based_on_status(saved_status)
      @sub_service_request.generate_approvals(@user, params)
      @sub_service_request.distribute_surveys if @sub_service_request.is_complete? and @sub_service_request.status != saved_status #status is complete and it was something different before
      @service_request = @sub_service_request.service_request
      @protocol = @service_request.protocol
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      email_users @sub_service_request if params[:status] == 'submitted'
      render 'portal/sub_service_requests/update_past_status', :formats => [:js]
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@sub_service_request.errors) }
      end
    end
  end

  def update_from_project_study_information
    @sub_service_request = SubServiceRequest.find params[:id]

    attrs = if @protocol.type.downcase.to_sym == :study && params[:study]
      params[:study]
    elsif @protocol.type.downcase.to_sym == :project && params[:project]
      params[:project]
    else
      Hash.new
    end

    if @protocol.update_attributes(attrs)
      redirect_to portal_admin_sub_service_request_path(@sub_service_request)
    else
      # @user_toasts set to an empty array for Wenjun's sanity until bootstrap is merged in
      # @user_toasts = @user.received_toast_messages.select {|x| x.sending_class == 'SubServiceRequest'}
      @user_toasts = []
      @service_request = @sub_service_request.service_request
      @protocol.populate_for_edit if @protocol.type == "Study"
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.one_time_fee}
      @subsidy = @sub_service_request.subsidy
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      @service_list = @service_request.service_list
      @related_service_requests = @protocol.all_child_sub_service_requests
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      @selected_arm = @service_request.arms.first
      # Sponsor name error showing up twice
      unless @protocol.errors.messages[:sponsor_name].nil?
        @protocol.errors.messages[:sponsor_name].uniq!
      end
      
      render action: 'show'

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
    service = Service.find(params[:new_service_id])
    percent = @subsidy.try(:percent_subsidy).try(:*, 100)
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}
    @candidate_per_patient_per_visit = @sub_service_request.candidate_services.reject {|x| x.one_time_fee}
    existing_service_ids = @service_request.line_items.map(&:service_id)

    # we don't have arms and we are adding a new per patient per visit service
    if @service_request.arms.empty? and not service.one_time_fee
      @service_request.protocol.arms.create(name: 'Screening Phase', visit_count: 1, subject_count: 1)
    end

    @arm_id = params[:arm_id].to_i if params[:arm_id]
    @selected_arm = params[:arm_id] ? Arm.find(@arm_id) : @service_request.arms.first
    @study_tracker = params[:study_tracker] == "true"
    @line_items = @sub_service_request.line_items

    ActiveRecord::Base.transaction do
      if @new_line_items = @service_request.create_line_items_for_service(
        service: Service.find(params[:new_service_id]),
        optional: true,
        existing_service_ids: existing_service_ids,
        allow_duplicates: true)

        @new_line_items.each do |line_item|
          line_item.update_attribute(:sub_service_request_id, @sub_service_request.id)
          @sub_service_request.update_cwf_data_for_new_line_item(line_item)
        end

        # Have to reload the service request to get the correct direct cost total for the subsidy
        @subsidy.try(:sub_service_request).try(:reload)
        @subsidy.try(:fix_pi_contribution, percent)
      else
        respond_to do |format|
          format.js { render :status => 500, :json => clean_errors(@service_request.errors) }
        end
      end
    end

    # ##Single line item created
    # if @sub_service_request.create_line_item(
    #     service_id: params[:new_service_id],
    #     sub_service_request_id: params[:sub_service_request_id])
    #   # Have to reload the service request to get the correct direct cost total for the subsidy
    #   @subsidy.try(:sub_service_request).try(:reload)
    #   @subsidy.try(:fix_pi_contribution, percent)
    # else
    #   respond_to do |format|
    #     format.js { render :status => 500, :json => clean_errors(@sub_service_request.errors) }
    #   end
    # end
  end

  def add_otf_line_item
    @sub_service_request = SubServiceRequest.find(params[:id])
    @service_request = @sub_service_request.service_request
    @candidate_one_time_fees = @sub_service_request.candidate_services.select {|x| x.one_time_fee}

    @study_tracker = params[:study_tracker] == "true"
    @line_items = @sub_service_request.line_items
    
    if @sub_service_request.create_line_item(
        service_id: params[:new_service_id],
        sub_service_request_id: params[:sub_service_request_id])
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
    document_id = params[:document_id]
    docObject = @sub_service_request.documents.find(document_id) if document_id
    document = params[:document]

    if (not document or params[:doc_type] == "") and not document_id
      # collect errors
      errors << "You must select a document to upload" if not document # we did not provide a document
      errors << "You must select a document type" if params[:doc_type] == "" # we did not provide a document type
    elsif not document_id
      # we have a new document
      newDocument = Document.create :document => document, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other], :service_request_id => @service_request.id
      @sub_service_request.documents << newDocument
      @sub_service_request.save
    elsif document_id
      # we need to update an existing document
      if docObject.sub_service_requests.size > 1
        # if updating here will affect other ssr's docs, create a new document and remove association to old document.
        new_doc = document ? document : docObject.document # if no new document provided use the old document
        newDocument = Document.create :document => new_doc, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other], :service_request_id => @service_request.id
        @sub_service_request.documents << newDocument
        @sub_service_request.documents.delete docObject
        @sub_service_request.save
      else
        # updating this document will not affect other ssrs.
        new_doc = document ? document : docObject.document # if no new document provided use the old document
        docObject.update_attributes(:document => new_doc, :doc_type => params[:doc_type], :doc_type_other => params[:doc_type_other])
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
    document = service_request.protocol.documents.find params[:document_id]
    @tr_id = "#document_id_#{document.id}"

    sub_service_request.documents.delete document
    sub_service_request.save
    document.destroy if document.sub_service_requests.empty?
  end

  def edit_documents
    @sub_service_request = SubServiceRequest.find(params[:id])
    service_request = @sub_service_request.service_request
    @document = service_request.protocol.documents.find params[:document_id]
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
        Notifier.sub_service_request_deleted(project_role.identity, @sub_service_request, current_user).deliver unless project_role.identity.email.blank?
      end

      # notify service providers
      @sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
        Notifier.sub_service_request_deleted(service_provider.identity, @sub_service_request, current_user).deliver
      end
    end

    redirect_to "/portal/admin"
  end

  def push_to_epic
    sub_service_request = SubServiceRequest.find(params[:id])
    begin
      sub_service_request.service_request.protocol.push_to_epic(EPIC_INTERFACE)

      respond_to do |format|
        format.json {
          render(
              status: 200,
              json: {})
        }
      end
    rescue
      respond_to do |format|
        format.json {
          render(
              status: 500,
              json: [$!.message])
        }
      end
    end
  end

  def email_users sub_service_request
    @service_request = sub_service_request.service_request
    @protocol = @service_request.protocol
    @line_items = sub_service_request.line_items
    @service_list = @service_request.service_list

    # generate the excel for this service request
    xls = render_to_string "/service_requests/show", :formats => [:xlsx]

    # send e-mail to all folks with view and above
    @protocol.project_roles.each do |project_role|
      next if project_role.project_rights == 'none'
      Notifier.notify_user(project_role, @service_request, xls, false, current_user).deliver_now unless project_role.identity.email.blank?
    end

    # Check to see if we need to send notifications for epic.
    if USE_EPIC
      if @protocol.selected_for_epic
        @protocol.awaiting_approval_for_epic_push
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless QUEUE_EPIC
      end
    end
  end

private
  def protocol_authorizer
    @protocol = Protocol.find(params[:protocol_id])
    authorized_user = ProtocolAuthorizer.new(@protocol, @user)
    if (request.get? && !authorized_user.can_view?) || (!request.get? && !authorized_user.can_edit?)
      @protocol = nil
      render :partial => 'service_requests/authorization_error', :locals => {:error => "You are not allowed to access this protocol."}
    end
  end
end
