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
  before_action :set_rmid_api,              only: [:new, :edit]

  def index
    admin_orgs = current_user.authorized_admin_organizations
    @admin     = admin_orgs.any?

    @default_filter_params  = { show_archived: 0 }

    # if we are an admin we want to default to admin organizations
    if @admin
      @organizations = Dashboard::IdentityOrganizations.new(current_user.id).admin_organizations_with_protocols
      @default_filter_params[:admin_filter] = "for_admin #{current_user.id}"
    else
      @organizations = Dashboard::IdentityOrganizations.new(current_user.id).general_user_organizations_with_protocols
      @default_filter_params[:admin_filter] = "for_identity #{current_user.id}"
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

    #toggles the display of the breadcrumbs, navbar always displays
    session[:breadcrumbs].clear

    respond_to do |format|
      format.html {
        @protocol_filters = ProtocolFilter.latest_for_user(current_user.id, ProtocolFilter::MAX_FILTERS)
      }
      format.js {
        @protocol_filters = ProtocolFilter.latest_for_user(current_user.id, ProtocolFilter::MAX_FILTERS)
      }
      format.json {
        @protocol_count = @filterrific.find.length
        @protocols      = @filterrific.find.includes(:principal_investigators, :sub_service_requests).sorted(params[:sort], params[:order]).limit(params[:limit]).offset(params[:offset])
      }
      format.csv {
        @protocols = @filterrific.find.includes(:principal_investigators, :sub_service_requests).sorted(params[:sort], params[:order])

        send_data Protocol.to_csv(@protocols), filename: "sparcrequest_protocols.csv"
      }
    end
  end

  def show
    respond_to do |format|
      format.html {
        session[:breadcrumbs].clear.add_crumbs(protocol_id: @protocol.id)
        @permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
        @protocol_type      = @protocol.type.capitalize
      }
      format.js
      format.xlsx {
        @statuses_hidden = params[:statuses_hidden] || %w(draft first_draft)
        response.headers['Content-Disposition'] = "attachment; filename=\"(#{@protocol.id}) Consolidated #{@protocol.industry_funded? ? 'Corporate ' : ''}Study Budget.xlsx\""
      }
    end
  end

  def new
    controller          = ::ProtocolsController.new
    controller.request  = request
    controller.response = response
    controller.new
    @protocol = controller.instance_variable_get(:@protocol)
  end

  def create
    @protocol = protocol_params[:type].capitalize.constantize.new(protocol_params)

    if @protocol.valid?
      # if current user is not authorized, add them as an authorized user
      unless @protocol.primary_pi_role.identity == current_user
        @protocol.project_roles.new(identity: current_user, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save
      @protocol.service_requests.new(status: 'draft').save(validate: false)

      if Setting.get_value("use_epic") && @protocol.selected_for_epic
        @protocol.ensure_epic_user
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless Setting.get_value("queue_epic")
      end

      flash[:success] = I18n.t('protocols.created', protocol_type: @protocol.type)

      redirect_to dashboard_protocol_path(@protocol)
    else
      @errors = @protocol.errors
    end

    respond_to :js
  end

  def edit
    # Prevent STQ Errors from Controller
    @protocol.bypass_stq_validation = @protocol.selected_for_epic.nil?

    controller          = ::ProtocolsController.new
    controller.request  = request
    controller.response = response
    controller.instance_variable_set(:@protocol, @protocol)
    controller.edit

    @protocol = controller.instance_variable_get(:@protocol)
    @errors   = controller.instance_variable_get(:@errors)

    # Re-Assign bypass
    @protocol.bypass_stq_validation = @protocol.selected_for_epic.nil?

    session[:breadcrumbs].clear.add_crumbs(protocol_id: @protocol.id, edit_protocol: true)

    respond_to :html
  end

  def update
    unless params[:locked]
      permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
      # admin is not able to activate study_type_question_group

      @protocol.bypass_rmid_validation = @bypass_rmid_validation
      @protocol.bypass_stq_validation = @protocol.selected_for_epic.nil? && protocol_params[:selected_for_epic].nil?

      if @protocol.update_attributes(protocol_params)
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
    controller          = ::ProtocolsController.new
    controller.request  = request
    controller.response = response
    controller.update_protocol_type
    @protocol = controller.instance_variable_get(:@protocol)

    flash[:success] = t('protocols.change_type.updated')

    respond_to :js
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
    respond_to :js

    @permission_to_edit = @authorization.present? ? @authorization.can_edit? : false
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

  def build_with_owner_params
    service_providers = Identity.joins(:service_providers).where(service_providers: {
                                organization: Organization.authorized_for_identity(current_user.id) })
                                .distinct.order("last_name")

    service_providers.map{|s| [s.last_name_first, s.id]}
  end

  def filterrific_params
    params.require(:filterrific).permit(:identity_id,
      :search_name,
      :show_archived,
      :admin_filter,
      :search_query,
      :reset_filterrific,
      search_query: [:search_drop, :search_text],
      with_organization: [],
      with_status: [],
      with_owner: [])
  end

  def protocol_params
    # Fix identity_id nil problem when lazy loading is enabled
    # when lazy loadin is enabled, identity_id is merely ldap_uid, the identity may not exist in database yet, so we create it if necessary here
    if Setting.get_value("use_ldap") && Setting.get_value("lazy_load_ldap") && params[:primary_pi_role_attributes][:identity_id].present?
      params[:protocol][:primary_pi_role_attributes][:identity_id] = Identity.find_or_create(params[:protocol][:primary_pi_role_attributes][:identity_id]).id
    end

    # Sanitize date formats
    params[:protocol][:funding_start_date]           = sanitize_date params[:protocol][:funding_start_date]
    params[:protocol][:potential_funding_start_date] = sanitize_date params[:protocol][:potential_funding_start_date]
    params[:protocol][:guarantor_phone]              = sanitize_phone params[:protocol][:guarantor_phone]

    if params[:protocol][:human_subjects_info_attributes]
      params[:protocol][:human_subjects_info_attributes][:initial_irb_approval_date] = sanitize_date params[:protocol][:human_subjects_info_attributes][:initial_irb_approval_date]
      params[:protocol][:human_subjects_info_attributes][:irb_approval_date]         = sanitize_date params[:protocol][:human_subjects_info_attributes][:irb_approval_date]
      params[:protocol][:human_subjects_info_attributes][:irb_expiration_date]       = sanitize_date params[:protocol][:human_subjects_info_attributes][:irb_expiration_date]
    end

    if params[:protocol][:vertebrate_animals_info_attributes]
      params[:protocol][:vertebrate_animals_info_attributes][:iacuc_approval_date]   = sanitize_date params[:protocol][:vertebrate_animals_info_attributes][:iacuc_approval_date]
      params[:protocol][:vertebrate_animals_info_attributes][:iacuc_expiration_date] = sanitize_date params[:protocol][:vertebrate_animals_info_attributes][:iacuc_expiration_date]
    end

    params.require(:protocol).permit(
      :archived,
      :arms_attributes,
      :billing_business_manager_static_email,
      :brief_description,
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
      :guarantor_contact,
      :guarantor_email,
      :guarantor_phone,
      :identity_id,
      :indirect_cost_rate,
      :last_epic_push_status,
      :last_epic_push_time,
      :next_ssr_id,
      :potential_funding_source,
      :potential_funding_source_other,
      :potential_funding_start_date,
      :requester_id,
      :research_master_id,
      :selected_for_epic,
      :short_title,
      :sponsor_name,
      :study_type_question_group_id,
      :title,
      :type,
      :udak_project_number,
      affiliations_attributes: [:id, :name, :new, :position, :_destroy],
      human_subjects_info_attributes: [:id, :nct_number, :pro_number, :irb_of_record, :submission_type, :initial_irb_approval_date, :irb_approval_date, :irb_expiration_date, :approval_pending],
      impact_areas_attributes: [:id, :name, :other_text, :new, :_destroy],
      investigational_products_info_attributes: [:id, :protocol_id, :ind_number, :inv_device_number, :exemption_type, :ind_on_hold],
      ip_patents_info_attributes: [:id, :patent_number, :inventors],
      primary_pi_role_attributes: [:id, :identity_id, :_destroy],
      research_types_info_attributes: [:id, :human_subjects, :vertebrate_animals, :investigational_products, :ip_patents],
      study_phase_ids: [],
      study_types_attributes: [:id, :name, :new, :position, :_destroy],
      study_type_answers_attributes: [:id, :answer, :study_type_question_id, :_destroy],
      vertebrate_animals_info_attributes: [:id, :iacuc_number, :name_of_iacuc, :iacuc_approval_date, :iacuc_expiration_date]
    )
  end

  def perform_protocol_lock(protocol, lock_status)
    if lock_status == 'true'
      protocol.update_attributes(locked: false)
    else
      protocol.update_attributes(locked: true)
    end
  end
end
