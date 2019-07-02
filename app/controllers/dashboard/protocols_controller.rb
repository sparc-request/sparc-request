# Copyright © 2011-2019 MUSC Foundation for Research Development
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

  before_action :find_protocol,             only: [:show, :edit, :update, :update_protocol_type, :display_requests, :archive]
  before_action :find_admin_for_protocol,   only: [:show, :edit, :update, :update_protocol_type, :display_requests, :archive]
  before_action :protocol_authorizer_view,  only: [:show, :view_full_calendar, :display_requests]
  before_action :protocol_authorizer_edit,  only: [:edit, :update, :update_protocol_type, :archive]
  before_action :bypass_rmid_validations?,  only: [:update, :edit]
  before_action :check_rmid_server_status,  only: [:new, :create, :edit, :update, :update_protocol_type]

  def index
    admin_orgs = @user.authorized_admin_organizations
    @admin     = admin_orgs.any?

    @default_filter_params = { show_archived: 0, sorted_by: 'id desc' }

    # if we are an admin we want to default to admin organizations
    if @admin
      @organizations = Dashboard::IdentityOrganizations.new(@user.id).admin_organizations_with_protocols
      @default_filter_params[:admin_filter] = "for_admin #{@user.id}"
    else
      @organizations = Dashboard::IdentityOrganizations.new(@user.id).general_user_organizations_with_protocols
      @default_filter_params[:admin_filter] = "for_identity #{@user.id}"
    end

    @filterrific =
      initialize_filterrific(Protocol, params[:filterrific] && filterrific_params,
        default_filter_params: @default_filter_params,
        select_options: {
          with_status: PermissibleValue.get_inverted_hash('status'),
          with_organization: Dashboard::GroupedOrganizations.new(@organizations).collect_grouped_options,
          with_owner: build_with_owner_params
        },
        persistence_id: false #selected filters remain the same on page reload
      ) || return

    @protocols        = @filterrific.find.page(params[:page])
    @admin_protocols  = Protocol.for_admin(@user.id).pluck(:id)
    @protocol_filters = ProtocolFilter.latest_for_user(@user.id, ProtocolFilter::MAX_FILTERS)

    #toggles the display of the breadcrumbs, navbar always displays
    @disable_breadcrumb  = true
    session[:breadcrumbs].clear

    setup_sorting_variables

    respond_to do |format|
      format.html
      format.js
      format.csv { send_data Protocol.to_csv(@filterrific.find), :filename => "dashboard_protocols.csv"}
    end
  end

  def show
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
        response.headers['Content-Disposition'] = "attachment; filename=\"(#{@protocol.id}) Consolidated #{@protocol.industry_funded? ? 'Corporate ' : ''}Study Budget.xlsx\""
      }
      format.pdf {
        response.headers['Content-Disposition'] = "attachment; filename=\"(#{@protocol.id}).pdf\""
        pdf = Prawn::Document.new(:page_layout => :landscape)
        generator = CostAnalysis::Generator.new
        generator.protocol = @protocol
        generator.to_pdf(pdf)
        send_data pdf.render, filename: "Cost Analysis (#{@protocol.id}).pdf", type: "application/pdf", disposition: "inline"
      }
    end
  end

  def new
    @protocol_type          = params[:protocol_type]
    @protocol               = @protocol_type.capitalize.constantize.new
    @protocol.requester_id  = current_user.id
    @protocol.populate_for_edit
    session[:protocol_type] = params[:protocol_type]
    gon.rm_id_api_url = Setting.get_value("research_master_api")
    gon.rm_id_api_token = Setting.get_value("rmid_api_token")
  end

  def create
    protocol_class                          = protocol_params[:type].capitalize.constantize
    ### if lazy load enabled, we need create the identiy if necessary here
    attrs                                   = Setting.get_value("use_ldap") && Setting.get_value("lazy_load_ldap") ? fix_identity : fix_date_params
    @protocol                               = protocol_class.new(attrs)
    @protocol.study_type_question_group_id  = StudyTypeQuestionGroup.active_id

    if @protocol.valid?
      unless @protocol.project_roles.map(&:identity_id).include? current_user.id
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save

      @protocol.service_requests.new(status: 'draft').save(validate: false)

      if Setting.get_value("use_epic") && @protocol.selected_for_epic
        @protocol.ensure_epic_user
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless Setting.get_value("queue_epic")
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
    gon.rm_id_api_url = Setting.get_value("research_master_api")
    gon.rm_id_api_token = Setting.get_value("rmid_api_token")

    session[:breadcrumbs].
      clear.
      add_crumbs(protocol_id: @protocol.id, edit_protocol: true)

    @protocol.valid?
    @errors = @protocol.errors
    @errors.delete(:research_master_id) if @bypass_rmid_validation

    respond_to do |format|
      format.html
    end
  end

  def update
    unless params[:locked]
      protocol_type = protocol_params[:type]
      @protocol = @protocol.becomes(protocol_type.constantize) unless protocol_type.nil?
      if (params[:updated_protocol_type] == 'true' && protocol_type == 'Study') || params[:can_edit] == 'true'
        @protocol.assign_attributes(study_type_question_group_id: StudyTypeQuestionGroup.active_id)
        @protocol.assign_attributes(selected_for_epic: protocol_params[:selected_for_epic]) if protocol_params[:selected_for_epic]
        if @protocol.valid?
          @protocol.update_attribute(:type, protocol_type)
          @protocol.activate
          @protocol.reload
        end
      end

      attrs               = fix_date_params
      permission_to_edit  = @authorization.present? ? @authorization.can_edit? : false
      # admin is not able to activate study_type_question_group

      @protocol.bypass_rmid_validation = @bypass_rmid_validation

      if @protocol.update_attributes(attrs)
        flash[:success] = I18n.t('protocols.updated', protocol_type: @protocol.type)
      else
        @errors = @protocol.errors
      end

      if params[:sub_service_request]
        @sub_service_request = SubServiceRequest.find params[:sub_service_request][:id]
        render "/dashboard/sub_service_requests/update"
      end
    else
      perform_protocol_lock(@protocol, params[:locked])
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

    #### switching to a Project should clear out RMID and RMID validated flag ####
    if @protocol_type && @protocol_type == 'Project'
      @protocol.update_attribute :research_master_id, nil
      @protocol.update_attribute :rmid_validated, false
    end
    #### end clearing RMID and RMID validated flag ####

    @protocol.populate_for_edit

    flash[:success] = t(:protocols)[:change_type][:updated]
    if @protocol_type == "Study" && @protocol.sponsor_name.nil? && @protocol.selected_for_epic.nil?
      flash[:alert] = t(:protocols)[:change_type][:new_study_warning]
    end
  end

  def archive
    @protocol.toggle!(:archived)

    @protocol_type      = @protocol.type
    @permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
    action = @protocol.archived ? 'archive' : 'unarchive'

    @protocol.notes.create(identity: current_user, body: t("protocols.summary.#{action}_note", protocol_type: @protocol_type))
    ProtocolMailer.with(protocol: @protocol, archiver: current_user, action: action).archive_email.deliver

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

  private

  def filterrific_params
    params.require(:filterrific).permit(:identity_id,
      :search_name,
      :show_archived,
      :admin_filter,
      :search_query,
      :sorted_by,
      :reset_filterrific,
      search_query: [:search_drop, :search_text],
      with_organization: [],
      with_status: [],
      with_owner: [])
  end

  def protocol_params
    @protocol_params ||= begin
        params.require(:protocol).permit(:archived,
        :arms_attributes,
        :billing_business_manager_static_email,
        :brief_description,
        :end_date,
        :federal_grant_code_id,
        :federal_grant_serial_number,
        :federal_grant_title,
        :federal_non_phs_sponsor,
        :federal_phs_sponsor,
        :funding_rfa,
        :funding_source,
        :funding_source_other,
        :funding_start_date,
        :funding_status,
        :identity_id,
        :indirect_cost_rate,
        :last_epic_push_status,
        :last_epic_push_time,
        :next_ssr_id,
        :potential_funding_source,
        :potential_funding_source_other,
        :potential_funding_start_date,
        :recruitment_end_date,
        :recruitment_start_date,
        :requester_id,
        :selected_for_epic,
        :short_title,
        :sponsor_name,
        :locked,
        {:study_phase_ids => []},
        :start_date,
        :study_type_question_group_id,
        :title,
        :type,
        :udak_project_number,
        :guarantor_contact,
        :guarantor_phone,
        :guarantor_email,
        :research_master_id,
        research_types_info_attributes: [:id, :human_subjects, :vertebrate_animals, :investigational_products, :ip_patents],
        study_types_attributes: [:id, :name, :new, :position, :_destroy],
        vertebrate_animals_info_attributes: [:id, :iacuc_number,
          :name_of_iacuc,
          :iacuc_approval_date,
          :iacuc_expiration_date],
        investigational_products_info_attributes: [:id, :protocol_id,
          :ind_number,
          :inv_device_number,
          :exemption_type,
          :ind_on_hold],
        ip_patents_info_attributes: [:id, :patent_number, :inventors],
        impact_areas_attributes: [:id, :name, :other_text, :new, :_destroy],
        human_subjects_info_attributes: [:id, :nct_number, :pro_number, :irb_of_record, :submission_type, :initial_irb_approval_date, :irb_approval_date, :irb_expiration_date, :approval_pending],
        affiliations_attributes: [:id, :name, :new, :position, :_destroy],
        project_roles_attributes: [:id, :identity_id, :role, :project_rights, :_destroy],
        study_type_answers_attributes: [:id, :answer, :study_type_question_id, :_destroy])
    end
  end

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
    @filterrific_params = params[:filterrific] ? filterrific_params.except(:sorted_by) : @default_filter_params
    @page               = params[:page]
    @sorted_by          = filterrific_params[:sorted_by] if params[:filterrific]
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

  ### fix identity id nil problem when lazy loading is enabled
  ### when lazy loadin is enabled, identity_id is merely ldap_uid, the identity may not exist in database yet, so we create it if necessary here
  def fix_identity
    attrs               = protocol_params
    attrs[:project_roles_attributes].each do |index, project_role|
      if project_role[:identity_id].present?
        identity = Identity.find_or_create project_role[:identity_id]
        project_role[:identity_id] = identity.id
      end
    end unless attrs[:project_roles_attributes].nil?
    attrs
  end

  def fix_date_params
    attrs               = protocol_params

    #### fix dates so they are saved correctly ####
    attrs                                        = convert_date_for_save attrs, :start_date
    attrs                                        = convert_date_for_save attrs, :end_date
    attrs                                        = convert_date_for_save attrs, :funding_start_date
    attrs                                        = convert_date_for_save attrs, :potential_funding_start_date

    if attrs[:human_subjects_info_attributes]
      attrs[:human_subjects_info_attributes]     = convert_date_for_save attrs[:human_subjects_info_attributes], :initial_irb_approval_date
      attrs[:human_subjects_info_attributes]     = convert_date_for_save attrs[:human_subjects_info_attributes], :irb_approval_date
      attrs[:human_subjects_info_attributes]     = convert_date_for_save attrs[:human_subjects_info_attributes], :irb_expiration_date
    end

    if attrs[:vertebrate_animals_info_attributes]
      attrs[:vertebrate_animals_info_attributes] = convert_date_for_save attrs[:vertebrate_animals_info_attributes], :iacuc_approval_date
      attrs[:vertebrate_animals_info_attributes] = convert_date_for_save attrs[:vertebrate_animals_info_attributes], :iacuc_expiration_date
    end

    attrs
  end

  def perform_protocol_lock(protocol, lock_status)
    if lock_status == 'true'
      protocol.update_attributes(locked: false)
    else
      protocol.update_attributes(locked: true)
    end
  end
end
