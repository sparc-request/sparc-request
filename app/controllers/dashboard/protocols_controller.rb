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

class Dashboard::ProtocolsController < Dashboard::BaseController

  respond_to :html, :json, :xlsx

  before_filter :find_protocol, only: [:show, :edit, :update, :update_protocol_type, :display_requests, :archive, :view_full_calendar, :view_details]
  before_filter :protocol_authorizer_view, only: [:show, :view_full_calendar, :display_requests]
  before_filter :protocol_authorizer_edit, only: [:edit, :update, :update_protocol_type]

  def index
    admin_orgs   = @user.authorized_admin_organizations
    @admin       = !admin_orgs.empty?
    @filterrific =
      initialize_filterrific(Protocol, params[:filterrific],
        default_filter_params: { show_archived: 0, for_identity_id: @user.id },
        select_options: {
          with_status: AVAILABLE_STATUSES.invert,
          with_core: admin_orgs.map { |org| [org.name, org.id] }
        },
        persistence_id: false #resets filters on page reload
      ) || return

    @protocols        = @filterrific.find.page(params[:page])
    @protocol_filters = ProtocolFilter.latest_for_user(@user.id, 5)
    session[:breadcrumbs].clear

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @protocol_role = @protocol.project_roles.find_by(identity_id: @user.id)

    respond_to do |format|
      format.js   { render }
      format.html {
        session[:breadcrumbs].clear.add_crumbs(protocol_id: @protocol.id)
        @permission_to_edit = @authorization.can_edit?
        @protocol_type = @protocol.type.capitalize
        @service_requests = @protocol.service_requests
        render
      }
      format.xlsx { render }
    end
  end

  def new
    admin_orgs = @user.authorized_admin_organizations
    @admin =  !admin_orgs.empty?
    @protocol_type = params[:protocol_type]
    @protocol = @protocol_type.capitalize.constantize.new
    @protocol.requester_id = current_user.id
    @protocol.populate_for_edit
    session[:protocol_type] = params[:protocol_type]
  end

  def create
    protocol_class = params[:protocol][:type].capitalize.constantize
    @protocol = protocol_class.create(params[:protocol])

    if @protocol.valid?
      if @protocol.project_roles.where(identity_id: current_user.id).empty?
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
        @protocol.save
      end

      if USE_EPIC && @protocol.selected_for_epic
        @protocol.ensure_epic_user
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless QUEUE_EPIC
      end

      flash[:success] = "#{@protocol.type} Created!"
    else
      @errors = @protocol.errors
    end
  end

  def edit
    admin_orgs          = @user.authorized_admin_organizations
    @admin              = !admin_orgs.empty?
    @protocol_type      = @protocol.type
    protocol_role       = @protocol.project_roles.find_by(identity_id: @user.id)
    @permission_to_edit = protocol_role.nil? ? false : protocol_role.can_edit?

    @protocol.populate_for_edit
    session[:breadcrumbs].
      clear.
      add_crumbs(protocol_id: @protocol.id, edit_protocol: true)
    
    @protocol.valid?
    @errors = @protocol.errors
    
    respond_to do |format|
      format.html
    end
  end

  def update
    attrs      = params[:protocol]
    admin_orgs = @user.authorized_admin_organizations
    @admin     = !admin_orgs.empty?
    
    # admin is not able to activate study_type_question_group
    if @admin && @protocol.update_attributes(attrs)
      flash[:success] = "#{@protocol.type} Updated!"
    elsif !@admin && @protocol.update_attributes(attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active_id))
      flash[:success] = "#{@protocol.type} Updated!"
    else
      @errors = @protocol.errors
    end
  end

  def update_protocol_type
    # Using update_attribute here is intentional, type is a protected attribute
    admin_orgs = @user.authorized_admin_organizations
    @admin =  !admin_orgs.empty?
    @protocol_type = params[:type]
    @protocol.update_attribute(:type, @protocol_type)
    conditionally_activate_protocol
    @protocol = Protocol.find @protocol.id #Protocol type has been converted, this is a reload
    @protocol.populate_for_edit
    flash[:success] = "Protocol Type Updated!"
  end

  def archive
    @protocol.toggle!(:archived)
    respond_to do |format|
      format.js
    end
  end

  def view_full_calendar
    @service_request = @protocol.any_service_requests_to_display?

    arm_id = params[:arm_id] if params[:arm_id]
    page = params[:page] if params[:page]
    session[:service_calendar_pages] = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id] = page if page && arm_id
    @tab = 'calendar'
    @portal = params[:portal]
    if @service_request
      @pages = {}
      @protocol.arms.each do |arm|
        new_page = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
        @pages[arm.id] = @service_request.set_visit_page(new_page, arm)
      end
    end
    @merged = true
    respond_to do |format|
      format.js
    end
  end

  def display_requests
    @protocol_role = @protocol.project_roles.find_by(identity_id: @user.id)

    @permission_to_edit = @protocol_role.present? ? @protocol_role.can_edit? : Protocol.for_admin(@user.id).include?(@protocol)
  end

  def view_details
    respond_to do |format|
      format.js
    end
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

  def admin?
    !@user.authorized_admin_organizations.empty?
  end

  def conditionally_activate_protocol
    if admin?
      if @protocol_type == "Study" && @protocol.virgin_project?
        @protocol.activate
      end
    else
      @protocol.activate
    end
  end
end
