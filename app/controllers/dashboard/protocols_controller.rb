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

  before_filter :find_protocol, only: [:show, :view_full_calendar, :update_from_fulfillment, :edit, :update, :update_protocol_type, :display_requests]
  before_filter :protocol_authorizer_view, only: [:show, :view_full_calendar]
  before_filter :protocol_authorizer_edit, only: [:update_from_fulfillment, :edit, :update, :update_protocol_type]

  def index
    @filterrific =
      initialize_filterrific(Protocol, params[:filterrific],
        select_options: {
          with_status: AVAILABLE_STATUSES.invert,
          with_core: @user.authorized_admin_organizations.map{ |org| [org.name, org.id] }
        },
        persistence_id: false #resets filters on page reload
    ) or return

    @protocols = @filterrific.find.page(params[:page])
    session[:breadcrumbs].clear

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @protocol_role = @protocol.project_roles.find_by_identity_id(@user.id)

    respond_to do |format|
      format.js   { render }
      format.html {
        session[:breadcrumbs].clear.add_crumbs(protocol_id: @protocol.id)
        @permission_to_edit = @protocol_role.can_edit?
        @protocol_type = @protocol.type.capitalize
        @service_requests = @protocol.service_requests
        render
      }
      format.xlsx { render }
    end
  end

  def new
    @protocol_type = params[:protocol_type]
    @protocol = @protocol_type.capitalize.constantize.new
    @protocol.requester_id = current_user.id
    @protocol.populate_for_edit
    session[:protocol_type] = params[:protocol_type]
  end

  def create
    protocol_class = params[:protocol][:type].capitalize.constantize
    @protocol = protocol_class.new(params[:protocol])
    unless @protocol.project_roles.map(&:identity_id).include?(current_user.id)
      # if current user is not authorized, add them as an authorized user
      @protocol.project_roles.new(identity_id: current_user.id, role: "general-access-user", project_rights: "approve")
    end

    if @protocol.valid?
      @protocol.save

      if USE_EPIC
        if @protocol.selected_for_epic
          @protocol.ensure_epic_user
          Notifier.notify_for_epic_user_approval(@protocol).deliver unless QUEUE_EPIC
        end
      end

      flash[:success] = "#{@protocol.type} Created!"
    else
      @errors = @protocol.errors
    end
  end

  def edit
    @protocol_type = @protocol.type
    @protocol.populate_for_edit
    session[:breadcrumbs].
      clear.
      add_crumbs(protocol_id: @protocol.id, edit_protocol: true)

    respond_to do |format|
      format.html
    end
  end

  def update
    attrs = params[@protocol.type.downcase.to_sym]
    attrs = attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)
    if @protocol.update_attributes attrs
      flash[:success] = "#{@protocol.type} Updated!"
    else
      @errors = @protocol.errors
    end
  end

  def update_protocol_type
    # Using update_attribute here is intentional, type is a protected attribute
    @protocol.update_attribute(:type, params[:type])
    @protocol_type = params[:type]
    @protocol = Protocol.find @protocol.id #Protocol type has been converted, this is a reload
    @protocol.populate_for_edit
    flash[:success] = "Protocol Type Updated!"
  end

  def update_from_fulfillment
    if @protocol.update_attributes(params[:protocol])
      render :nothing => true
    else
      respond_to do |format|
        format.js { render :status => 500, :json => clean_errors(@protocol.errors) }
      end
    end
  end

  # @TODO: add to an authorization filter?
  def add_associated_user
    @protocol = Protocol.find(params[:id])

    @project_role = @protocol.project_roles.build(:identity_id => @user.id)
    respond_to do |format|
      format.js
      format.html
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
        @pages[arm.id] = @service_request.set_visit_page new_page, arm
      end
    end
    @merged = true
    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

end
