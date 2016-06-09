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
  before_action :find_sub_service_request,  except: :index
  before_filter :protocol_authorizer,       only: :update_from_project_study_information
  before_filter :authorize_admin,           only: :show, unless: :format_js?

  respond_to :json, :js, :html

  def index
    service_request       = ServiceRequest.find(params[:srid])
    protocol              = service_request.protocol
    @admin_orgs           = @user.authorized_admin_organizations
    @permission_to_edit   = protocol.project_roles.where(identity_id: @user.id, project_rights: ['approve', 'request']).any?
    permission_to_view    = protocol.project_roles.where(identity_id: @user.id, project_rights: ['view', 'approve', 'request']).any?
    
    @sub_service_requests = if permission_to_view
                              service_request.sub_service_requests
                            else
                              sp_only_admin_orgs = @user.authorized_admin_organizations({ sp_only: true })

                              service_request.sub_service_requests.reject { |ssr| ssr.should_be_hidden_for_sp?(sp_only_admin_orgs) }
                            end
  end

  def show
    respond_to do |format|
      format.js { # User Modal Show
        arm_id                            = params[:arm_id] if params[:arm_id]
        page                              = params[:page]   if params[:page]
        session[:service_calendar_pages]  = params[:pages]  if params[:pages]
        
        if page && arm_id
          session[:service_calendar_pages]          = {} unless session[:service_calendar_pages].present?
          session[:service_calendar_pages][arm_id]  = page
        end

        @service_request  = @sub_service_request.service_request
        @service_list     = @service_request.service_list
        @line_items       = @sub_service_request.line_items
        @protocol         = @service_request.protocol
        @tab              = 'calendar'
        @portal           = true
        @thead_class      = 'default_calendar'
        @review           = true
        @selected_arm     = Arm.find arm_id if arm_id
        @pages            = {}

        @service_request.arms.each do |arm|
          new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
          @pages[arm.id] = @service_request.set_visit_page(new_page, arm)
        end

        render
      }

      format.html { # Admin Edit
        session[:service_calendar_pages] = params[:pages] if params[:pages]
        session[:breadcrumbs].add_crumbs(protocol_id: @sub_service_request.protocol.id, sub_service_request_id: @sub_service_request.id).clear(:notifications)
        
        if @user.can_edit_fulfillment?(@sub_service_request.organization)
          @service_request  = @sub_service_request.service_request
          @protocol         = @sub_service_request.protocol

          render
        else
          redirect_to dashboard_root_path
        end
      }
    end
  end

  def update
    if @sub_service_request.update_attributes(params[:sub_service_request])
      flash[:success] = 'Request Updated!'
    else
      @errors = @sub_service_request.errors
    end
  end

  def destroy
    @protocol = @sub_service_request.protocol
    if @sub_service_request.destroy
      # Delete all related toast messages
      ToastMessage.where(sending_class_id: params[:id], sending_class: 'SubServiceRequest').each(&:destroy)

      # notify users with view rights or above of deletion
      @protocol.project_roles.where.not(project_rights: "none").each do |project_role|
        Notifier.sub_service_request_deleted(project_role.identity, @sub_service_request, current_user).deliver unless project_role.identity.email.blank?
      end

      # notify service providers
      @sub_service_request.organization.service_providers.where.not(hold_emails: true).each do |service_provider|
        Notifier.sub_service_request_deleted(service_provider.identity, @sub_service_request, current_user).deliver
      end
      flash[:alert] = 'Request Destroyed!'
    end
  end

  def refresh_service_calendar
    @service_request  = @sub_service_request.service_request
    arm_id            = params[:arm_id].to_s if params[:arm_id]
    @arm              = Arm.find arm_id if arm_id
    @portal           = params[:portal] if params[:portal]
    @thead_class      = @portal == 'true' ? 'default_calendar' : 'red-provider'
    page              = params[:page] if params[:page]

    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id
    
    @pages = {}
    @service_request.arms.each do |arm|
      new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
      @pages[arm.id] = @service_request.set_visit_page(new_page, arm)
    end
    
    @tab = 'calendar'
  end

  def update_from_project_study_information
    attrs = params[@protocol.type.downcase.to_sym]

    if @protocol.update_attributes(attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first))
      redirect_to portal_admin_sub_service_request_path(@sub_service_request)
    else
      @user_toasts = @user.received_toast_messages.select { |x| x.sending_class == 'SubServiceRequest' }
      @service_request = @sub_service_request.service_request
      @protocol.populate_for_edit if @protocol.type == 'Study'
      @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition(&:one_time_fee)
      @subsidy = @sub_service_request.subsidy
      @notifications = @user.all_notifications.where(sub_service_request_id: @sub_service_request.id)
      @service_list = @service_request.service_list
      @related_service_requests = @protocol.all_child_sub_service_requests
      @approvals = [@service_request.approvals, @sub_service_request.approvals].flatten
      @selected_arm = @service_request.arms.first

      render action: 'show'
    end
  end

  def push_to_epic
    begin
      @sub_service_request.service_request.protocol.push_to_epic(EPIC_INTERFACE)
      flash[:success] = 'Request Pushed to Epic!'
    rescue
      flash[:alert] = $!.message
    end
  end

  #History Table Methods Begin
  def change_history_tab
    #Replaces currently displayed ssr history bootstrap table
    history_path = 'dashboard/sub_service_requests/history/'
    @partial_to_render = history_path + params[:partial]
  end

  def status_history
    #For Status History Bootstrap Table
    @past_statuses = @sub_service_request.past_status_lookup
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
      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this protocol.' }
    end
  end

  def authorize_admin
    unless (@user.authorized_admin_organizations & @sub_service_request.org_tree).any?
      @protocol = nil
      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
    end
  end

  def format_js?
    request.format.js?
  end
end
