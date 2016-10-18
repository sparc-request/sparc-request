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

class Dashboard::ProtocolsController < Dashboard::BaseController

  respond_to :html, :json, :xlsx

  before_filter :find_protocol,                                   only: [:show, :edit, :update, :update_protocol_type, :display_requests, :archive, :view_full_calendar, :view_details]
  before_filter :find_admin_for_protocol,                         only: [:show, :edit, :update, :update_protocol_type, :display_requests]
  before_filter :protocol_authorizer_view,                        only: [:show, :view_full_calendar, :display_requests]
  before_filter :protocol_authorizer_edit,                        only: [:edit, :update, :update_protocol_type]

  def index
    admin_orgs   = @user.authorized_admin_organizations
    @admin       = !admin_orgs.empty?

    @default_filter_params = { show_archived: 0 }

    # if we are an admin we want to default to admin organizations
    if @admin
      @organizations = Dashboard::IdentityOrganizations.new(@user.id).admin_organizations_with_protocols
      @default_filter_params[:admin_filter] = "for_admin #{@user.id}"
    else
      @organizations = Dashboard::IdentityOrganizations.new(@user.id).general_user_organizations_with_protocols
      @default_filter_params[:admin_filter] = "for_identity #{@user.id}"
      params[:filterrific][:admin_filter] = "for_identity #{@user.id}" if params[:filterrific]
    end

    @filterrific =
      initialize_filterrific(Protocol, params[:filterrific],
        default_filter_params: @default_filter_params,
        select_options: {
          with_status: AVAILABLE_STATUSES.invert,
          with_organization: Dashboard::GroupedOrganizations.new(@organizations).collect_grouped_options,
          with_owner: build_with_owner_params
        },
        persistence_id: false #resets filters on page reload
      ) || return

    @protocols          = @filterrific.find.page(params[:page])

    @admin_protocols    = Protocol.for_admin(@user.id).pluck(:id)
    @protocol_filters   = ProtocolFilter.latest_for_user(@user.id, 5)
    #toggles the display of the navigation bar, instead of breadcrumbs
    @show_navbar      = true
    @show_messages    = true
    session[:breadcrumbs].clear

    setup_sorting_variables

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    respond_to do |format|
      format.js   { render }
      format.html {
        session[:breadcrumbs].clear.add_crumbs(protocol_id: @protocol.id)
        @permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
        @protocol_type      = @protocol.type.capitalize

        render
      }
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"(#{@protocol.id}) Consolidated Corporate Study Budget.xlsx\""
      }
    end
  end

  def new
    @protocol_type          = params[:protocol_type]
    @protocol               = @protocol_type.capitalize.constantize.new
    @protocol.requester_id  = current_user.id
    @protocol.populate_for_edit
    session[:protocol_type] = params[:protocol_type]
  end

  def create
    protocol_class = params[:protocol][:type].capitalize.constantize

    attrs = fix_date_params

    @protocol = protocol_class.new(attrs)
    @protocol.study_type_question_group_id = StudyTypeQuestionGroup.active_id

    if @protocol.valid?
      unless @protocol.project_roles.map(&:identity_id).include? current_user.id
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save

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
    @protocol_type      = @protocol.type
    @permission_to_edit = @authorization.nil? ? false : @authorization.can_edit?

    if @permission_to_edit
      @protocol.study_type_question_group_id = StudyTypeQuestionGroup.active_id
    end

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
    attrs = fix_date_params

    permission_to_edit  = @authorization.present? ? @authorization.can_edit? : false

    # admin is not able to activate study_type_question_group
    if !permission_to_edit && @protocol.update_attributes(attrs)
      flash[:success] = "#{@protocol.type} Updated!"
    elsif permission_to_edit && @protocol.update_attributes(attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active_id))
      flash[:success] = "#{@protocol.type} Updated!"
    else
      @errors = @protocol.errors
    end

    if params[:sub_service_request]
      @sub_service_request = SubServiceRequest.find params[:sub_service_request][:id]
      render "/dashboard/sub_service_requests/update"
    end
  end

  def update_protocol_type
    # Using update_attribute here is intentional, type is a protected attribute
    protocol_role       = @protocol.project_roles.find_by(identity_id: @user.id)
    @permission_to_edit = protocol_role.nil? ? false : protocol_role.can_edit?
    @protocol_type      = params[:type]

    @protocol.update_attribute(:type, @protocol_type)
    conditionally_activate_protocol

    @protocol = Protocol.find(@protocol.id)#Protocol type has been converted, this is a reload
    @protocol.populate_for_edit

    flash[:success] = "Protocol Type Updated!"
    if @protocol_type == "Study" && @protocol.sponsor_name.nil? && @protocol.selected_for_epic.nil?
      flash[:alert] = "Please complete Sponsor Name and Publish Study in Epic"
    end
  end

  def archive
    @protocol.toggle!(:archived)
    respond_to do |format|
      format.js
    end
  end

  def view_full_calendar
    @service_request  = @protocol.any_service_requests_to_display?
    arm_id            = params[:arm_id] if params[:arm_id]
    page              = params[:page] if params[:page]

    session[:service_calendar_pages]          = params[:pages] if params[:pages]
    session[:service_calendar_pages][arm_id]  = page if page && arm_id

    @tab    = 'calendar'
    @portal = params[:portal]

    if @service_request
      @pages = {}
      @protocol.arms.each do |arm|
        new_page        = (session[:service_calendar_pages].nil?) ? 1 : session[:service_calendar_pages][arm.id.to_s].to_i
        @pages[arm.id]  = @service_request.set_visit_page(new_page, arm)
      end
    end

    @merged = true
    respond_to do |format|
      format.js
    end
  end

  def display_requests
    permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
    modal              = render_to_string(partial: 'dashboard/protocols/requests_modal', locals: { protocol: @protocol, user: @user, permission_to_edit: permission_to_edit })

    data = { modal: modal }
    render json: data
  end

  def view_details
    respond_to do |format|
      format.js
    end
  end

  private

  def build_with_owner_params
    service_providers = Identity.joins(:service_providers).where(service_providers: {
                                organization: Organization.authorized_for_identity(current_user.id) })
                                .distinct.order("last_name")

    service_providers.map{|s| [s.last_name_first, s.id]}
  end

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

  def setup_sorting_variables
    # Set filterrific params for sorting logic, store sorted by to re-apply styling
    @filterrific_params = params[:filterrific] ? params[:filterrific].except(:sorted_by) : @default_filter_params
    @page               = params[:page]
    @sorted_by          = params[:filterrific][:sorted_by] if params[:filterrific]
    @sort_name          = @sorted_by.split(' ')[0] if @sorted_by
    @sort_order         = @sorted_by.split(' ')[1] if @sorted_by
    @new_sort_order     = (@sort_order == 'asc' ? 'desc' : 'asc') if @sort_order
  end

  def conditionally_activate_protocol
    if @admin
      if @protocol_type == "Study" && @protocol.virgin_project?
        @protocol.activate
      end
    else
      @protocol.activate
    end
  end

  def convert_date_for_save(attrs, date_field)
    if attrs[date_field] && attrs[date_field].present?
      attrs[date_field] = Time.strptime(attrs[date_field].strip, "%m/%d/%Y")
    end

    attrs
  end

  def fix_date_params
    attrs               = params[:protocol]

    #### fix dates so they are saved correctly ####
    attrs                                        = convert_date_for_save attrs, :start_date
    attrs                                        = convert_date_for_save attrs, :end_date
    attrs                                        = convert_date_for_save attrs, :funding_start_date
    attrs                                        = convert_date_for_save attrs, :potential_funding_start_date

    if attrs[:human_subjects_info_attributes]
      attrs[:human_subjects_info_attributes]     = convert_date_for_save attrs[:human_subjects_info_attributes], :irb_approval_date
      attrs[:human_subjects_info_attributes]     = convert_date_for_save attrs[:human_subjects_info_attributes], :irb_expiration_date
    end

    if attrs[:vertebrate_animals_info_attributes]
      attrs[:vertebrate_animals_info_attributes] = convert_date_for_save attrs[:vertebrate_animals_info_attributes], :iacuc_approval_date
      attrs[:vertebrate_animals_info_attributes] = convert_date_for_save attrs[:vertebrate_animals_info_attributes], :iacuc_expiration_date
    end

    attrs
  end

end
