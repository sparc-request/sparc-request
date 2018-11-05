# Copyright © 2011-2018 MUSC Foundation for Research Development
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
  before_action :find_service_request,      only: :index
  before_action :find_permissions,          only: :index
  before_action :find_admin_orgs,           except: :refresh_tab, unless: :show_js?
  before_action :authorize_protocol,        only: :index
  before_action :authorize_admin,           except: [:index, :refresh_tab], unless: :show_js?

  respond_to :json, :js, :html

  def index
    service_request       = ServiceRequest.find(params[:srid])
    protocol              = service_request.protocol
    @admin_orgs           = @user.authorized_admin_organizations
    @sub_service_requests = service_request.sub_service_requests.where.not(status: 'first_draft') # TODO: Remove Historical first_draft SSRs and remove this
    @show_view_ssr_back   = params[:show_view_ssr_back]
    @sr_table             = params[:sr_table] || false
  end

  def show
    respond_to do |format|
      format.html { # Admin Edit
        cookies['admin-tab'] = 'details-tab' unless cookies['admin-tab']
        session[:service_calendar_pages] = params[:pages] if params[:pages]
        session[:breadcrumbs].add_crumbs(protocol_id: @sub_service_request.protocol.id, sub_service_request_id: @sub_service_request.id).clear(:notifications)

        @service_request  = @sub_service_request.service_request
        @protocol         = @sub_service_request.protocol

        render
      }

      format.js { # User Modal Show
        arm_id                            = params[:arm_id] if params[:arm_id]
        page                              = params[:page]   if params[:page]
        session[:service_calendar_pages]  = params[:pages]  if params[:pages]

        if page && arm_id
          session[:service_calendar_pages]          = {} unless session[:service_calendar_pages].present?
          session[:service_calendar_pages][arm_id]  = page
        end

        @service_request        = @sub_service_request.service_request
        @service_list           = @service_request.service_list
        @line_items             = @sub_service_request.line_items
        @protocol               = @service_request.protocol
        @tab                    = 'calendar'
        @portal                 = true
        @admin                  = false
        @review                 = true
        @merged                 = false
        @consolidated           = false
        @show_view_ssr_back     = params[:show_view_ssr_back] == "true"
        @display_all_services   = true
        @pages                  = {}
        @service_request.arms.each do |arm|
          new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
          @pages[arm.id] = @service_request.set_visit_page(new_page, arm)
        end

        render
      }
    end
  end

  def update
    if params[:check_sr_calendar] == 'true'
      sr = @sub_service_request.service_request
      sr.validate_service_calendar
      if sr.errors[:base].length > 0
        raise 'error'
      end
    end
    if @sub_service_request.update_attributes(sub_service_request_params)
      @sub_service_request.distribute_surveys if (@sub_service_request.status == 'complete' && sub_service_request_params[:status].present?)
      flash[:success] = 'Request Updated!'
    else
      @errors = @sub_service_request.errors
    end
  end

  def destroy
    @protocol = @sub_service_request.protocol
    if @sub_service_request.destroy
      notifier_logic = NotifierLogic.new(@sub_service_request.service_request, nil, current_user)
      notifier_logic.ssr_deletion_emails(deleted_ssr: @sub_service_request, ssr_destroyed: false, request_amendment: false, admin_delete_ssr: true)

      flash[:alert] = 'Request Destroyed!'
      session[:breadcrumbs].clear(:sub_service_request_id)
    end
  end

  def refresh_service_calendar
    @service_request  = @sub_service_request.service_request
    arm_id            = params[:arm_id].to_s if params[:arm_id]
    @arm              = Arm.find arm_id if arm_id
    @portal           = params[:portal] if params[:portal]
    @thead_class      = @portal == 'true' ? 'default_calendar' : 'red-provider'
    page              = params[:page] if params[:page]

    if params[:pages]
      session[:service_calendar_pages] = params[:pages].permit!.to_h
    end
    session[:service_calendar_pages][arm_id] = page if page && arm_id

    @pages = {}
    @service_request.arms.each do |arm|
      new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
      @pages[arm.id] = @service_request.set_visit_page(new_page, arm)
    end

    @tab = 'calendar'
  end

  def push_to_epic
    sr = @sub_service_request.service_request
    sr.validate_service_calendar
    unless sr.errors[:base].length > 0
      begin
        @sub_service_request.protocol.push_to_epic(EPIC_INTERFACE, "admin_push", current_user.id)
        flash[:success] = 'Request Pushed to Epic!'
      rescue
        flash[:alert] = $!.message
      end
    else
      raise 'error'
    end
  end

  def resend_surveys
    if @sub_service_request.surveys_completed?
      @refresh = true # Refresh the details options
      flash[:alert] = 'All surveys have already been completed.'
    else
      @sub_service_request.distribute_surveys
      flash[:success] = 'Surveys re-sent!'
    end
  end

  #History Table Methods Begin
  def change_history_tab
    #Replaces currently displayed ssr history bootstrap table
    history_path = 'dashboard/sub_service_requests/history/'
    @partial_to_render = history_path + params[:partial]
    @tab = params[:partial]
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

  def subsidy_history
    #For Subsidy History Bootstrap Table
    @subsidies = PastSubsidy.where(sub_service_request_id: @sub_service_request.id)
  end
  #History Table Methods End

  #Tab Change Ajax
  def refresh_tab
    @service_request = @sub_service_request.service_request
    @protocol = Protocol.find(params[:protocol_id])
    @partial_name = params[:partial_name]
  end


private

  def sub_service_request_params
      params.require(:sub_service_request).permit(:service_request_id,
        :ssr_id,
        :organization_id,
        :owner_id,
        :status,
        :consult_arranged_date,
        :nursing_nutrition_approved,
        :lab_approved,
        :imaging_approved,
        :committee_approved,
        :requester_contacted_date,
        :in_work_fulfillment,
        :routing,
        :documents,
        :service_requester_id,
        :requester_contacted_date,
        :submitted_at,
        :imported_to_fulfillment,
        line_items_attributes: [:service_request_id,
          :sub_service_request_id,
          :service_id,
          :optional,
          :complete_date,
          :in_process_date,
          :units_per_quantity,
          :quantity,
          :fulfillments_attributes,
          :displayed_cost,
          :_destroy])
  end

  def find_sub_service_request
    @sub_service_request = SubServiceRequest.find(params[:id])
  end

  def find_service_request
    @service_request = ServiceRequest.find(params[:srid])
  end

  def find_permissions
    @permission_to_edit = @user.can_edit_protocol?(@service_request.protocol)
    @permission_to_view = @permission_to_edit || @user.can_view_protocol?(@service_request.protocol)
  end

  def find_admin_orgs
    @admin_orgs = @user.authorized_admin_organizations
  end

  def authorize_protocol
    unless @permission_to_view || Protocol.for_admin(@user.id).include?(@service_request.protocol)
      @sub_service_request  = nil
      @service_request      = nil
      @permission_to_edit   = nil
      @permission_to_view   = nil

      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
    end
  end

  def authorize_admin
    unless (@admin_orgs & @sub_service_request.org_tree).any?
      @sub_service_request = nil
      render partial: 'service_requests/authorization_error', locals: { error: 'You are not allowed to access this Sub Service Request.' }
    end
  end

  def show_js?
    action_name == 'show' && request.format.js?
  end
end
