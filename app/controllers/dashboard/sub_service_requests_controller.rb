# Copyright © 2011 MUSC Foundation for Research Development
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

class Dashboard::SubServiceRequestsController < Dashboard::BaseController
  respond_to :json, :js, :html
  before_action :find_sub_service_request
  before_filter :protocol_authorizer, :only => [:update_from_project_study_information]

  def show
    @admin = true
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:breadcrumbs].add_crumbs(protocol_id: @sub_service_request.service_request.protocol_id, sub_service_request_id: @sub_service_request.id).clear(:notifications)
    if @user.can_edit_fulfillment? @sub_service_request.organization
      @service_request = @sub_service_request.service_request
      @protocol = @sub_service_request.protocol
    else
      redirect_to dashboard_root_path
    end
  end

  def update
    if @sub_service_request.update_attributes(params[:sub_service_request])
      flash[:success] = "Request Updated!"
    else
      @errors = @sub_service_request.errors
    end
  end

  def destroy
    @protocol = @sub_service_request.protocol
    if @sub_service_request.destroy
      # Delete all related toast messages
      ToastMessage.where(:sending_class_id => params[:id]).where(:sending_class => "SubServiceRequest").each do |toast|
        toast.destroy
      end

      # notify users with view rights or above of deletion
      @protocol.project_roles.each do |project_role|
        next if project_role.project_rights == 'none'
        Notifier.sub_service_request_deleted(project_role.identity, @sub_service_request, current_user).deliver unless project_role.identity.email.blank?
      end

      # notify service providers
      @sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
        Notifier.sub_service_request_deleted(service_provider.identity, @sub_service_request, current_user).deliver
      end
      flash[:alert] = "Request Destroyed!"
    end
  end

  def update_from_project_study_information
    attrs = params[@protocol.type.downcase.to_sym]

    if @protocol.update_attributes(attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first))
      redirect_to portal_admin_sub_service_request_path(@sub_service_request)
    else
      @user_toasts = @user.received_toast_messages.select {|x| x.sending_class == 'SubServiceRequest'}
      @service_request = @sub_service_request.service_request
      @protocol.populate_for_edit if @protocol.type == "Study"
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.one_time_fee}
      @subsidy = @sub_service_request.subsidy
      @notifications = @user.all_notifications.where(:sub_service_request_id => @sub_service_request.id)
      @service_list = @service_request.service_list
      @related_service_requests = @protocol.all_child_sub_service_requests
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      @selected_arm = @service_request.arms.first

      render :action => 'show'

    end
  end

  def push_to_epic
    begin
      @sub_service_request.service_request.protocol.push_to_epic(EPIC_INTERFACE)
      flash[:success] = "Request Pushed to Epic!"
    rescue
      flash[:alert] = $!.message
    end
  end

  #History Table Methods Begin
  def change_history_tab
    #Replaces currently displayed ssr history bootstrap table
    history_path = "dashboard/sub_service_requests/history/"
    @partial_to_render = history_path + params[:partial]
  end

  def status_history
    #For Status History Bootstrap Table
    @past_statuses = @sub_service_request.past_status_lookup
  end

  def subsidy_history
    #For Subsidy History Bootstrap Table
    @subsidy_audits = []
    subsidy = @sub_service_request.subsidy
    if subsidy
      @subsidy_audits = @sub_service_request.subsidy.subsidy_audits
    end
  end

  def approval_history
    #For Approval History Bootstrap Table
    service_request = @sub_service_request.service_request
    @approvals = [service_request.approvals, @sub_service_request.approvals].flatten
  end
  #History Table Methods End

private

  def find_sub_service_request
    @sub_service_request = SubServiceRequest.find(params[:id])
  end

  def protocol_authorizer
    @protocol = Protocol.find(params[:protocol_id])
    authorized_user = ProtocolAuthorizer.new(@protocol, @user)
    if (request.get? && !authorized_user.can_view?) || (!request.get? && !authorized_user.can_edit?)
      @protocol = nil
      render :partial => 'service_requests/authorization_error', :locals => {:error => "You are not allowed to access this protocol."}
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
end
