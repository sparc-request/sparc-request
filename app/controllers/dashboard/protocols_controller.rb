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
  before_filter :find_protocol,                                   only: [:show, :edit, :update, :update_protocol_type, :display_requests, :archive, :view_details]
  before_filter :find_admin_for_protocol,                         only: [:show, :edit, :update, :update_protocol_type, :display_requests]
  before_filter :protocol_authorizer_view,                        only: [:show, :view_full_calendar, :display_requests]
  before_filter :protocol_authorizer_edit,                        only: [:edit, :update, :update_protocol_type]

  def index
    admin_orgs   = @user.authorized_admin_organizations
    @admin       = !admin_orgs.empty?

    @default_filter_params = { show_archived: 0, sorted_by: 'id desc' }

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

    @protocols        = @filterrific.find.page(params[:page])
    @admin_protocols  = Protocol.for_admin(@user.id).pluck(:id)
    @protocol_filters = ProtocolFilter.latest_for_user(@user.id, 5)

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
    @submissions = @protocol.submissions
    respond_to do |format|
      format.html {
        session[:breadcrumbs].clear.add_crumbs(protocol_id: @protocol.id)
        @permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
        @protocol_type      = @protocol.type.capitalize
        @show_view_ssr_back = false

        render
      }
      format.xlsx {
        @statuses_hidden = params[:statuses_hidden] || %w(draft first_draft)
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
    gon.rm_id_api_url = RESEARCH_MASTER_API
    gon.rm_id_api_token = RMID_API_TOKEN
  end

  def create
    protocol_class                          = params[:protocol][:type].capitalize.constantize
    attrs                                   = fix_date_params
    @protocol                               = protocol_class.new(attrs)
    @protocol.study_type_question_group_id  = StudyTypeQuestionGroup.active_id

    if @protocol.valid?
      unless @protocol.project_roles.map(&:identity_id).include? current_user.id
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save

      @protocol.service_requests.new(status: 'draft').save(validate: false)

      if USE_EPIC && @protocol.selected_for_epic
        @protocol.ensure_epic_user
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless QUEUE_EPIC
      end

      flash[:success] = I18n.t('protocols.created', protocol_type: @protocol.type)
    else
      @errors = @protocol.errors
    end
  end

  def edit
    @protocol_type      = @protocol.type
    @permission_to_edit = @authorization.nil? ? false : @authorization.can_edit?
    @in_dashboard       = true
    @protocol.populate_for_edit
    gon.rm_id_api_url = RESEARCH_MASTER_API
    gon.rm_id_api_token = RMID_API_TOKEN

    session[:breadcrumbs].
      clear.
      add_crumbs(protocol_id: @protocol.id, edit_protocol: true)

    @protocol.valid?
    @errors = @protocol.errors
    @errors.delete(:research_master_id) if @admin

    respond_to do |format|
      format.html
    end
  end

  def update
    protocol_type = params[:protocol][:type]
    @protocol = @protocol.becomes(protocol_type.constantize) unless protocol_type.nil?
    if params[:updated_protocol_type] == 'true' && protocol_type == 'Study'
      @protocol.update_attribute(:type, protocol_type)
      @protocol.activate
      @protocol.reload
    end

    attrs               = fix_date_params
    permission_to_edit  = @authorization.present? ? @authorization.can_edit? : false
    # admin is not able to activate study_type_question_group

    if save_protocol_with_blank_rmid_if_admin(attrs)
      flash[:success] = I18n.t('protocols.updated', protocol_type: @protocol.type)
    else
      @errors = @protocol.errors
    end

    if params[:sub_service_request]
      @sub_service_request = SubServiceRequest.find params[:sub_service_request][:id]
      render "/dashboard/sub_service_requests/update"
    end
  end

  def update_protocol_type
    protocol_role       = @protocol.project_roles.find_by(identity_id: @user.id)
    @permission_to_edit = protocol_role.nil? ? false : protocol_role.can_edit?

    # Setting type and study_type_question_group, not actually saving
    @protocol.type      = params[:type]
    @protocol.study_type_question_group_id = StudyTypeQuestionGroup.active_id

    @protocol_type = params[:type]

    @protocol = @protocol.becomes(@protocol_type.constantize) unless @protocol_type.nil?
    @protocol.populate_for_edit

    flash[:success] = t(:protocols)[:change_type][:updated]
    if @protocol_type == "Study" && @protocol.sponsor_name.nil? && @protocol.selected_for_epic.nil?
      flash[:alert] = t(:protocols)[:change_type][:new_study_warning]
    end
  end

  def archive
    @protocol.toggle!(:archived)
    respond_to do |format|
      format.js
    end
  end

  def display_requests
    permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
    modal              = render_to_string(partial: 'dashboard/protocols/requests_modal', locals: { protocol: @protocol, user: @user, permission_to_edit: permission_to_edit, show_view_ssr_back: true })

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

  def save_protocol_with_blank_rmid_if_admin(attrs)
    @protocol.assign_attributes(attrs)
    if @admin && !@protocol.valid? && @protocol.errors.full_messages == ["Research master can't be blank"]
      @protocol.save(validate: false)
    else
      @protocol.errors.delete(:research_master_id) if @admin
      @protocol.save
    end
  end
end
