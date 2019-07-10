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

class ProtocolsController < ApplicationController

  respond_to :html, :js, :json
  protect_from_forgery except: :show

  before_action :initialize_service_request,  except: [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_action :authorize_identity,          except: [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_action :find_protocol,               only: [:edit, :update, :show]
  before_action :check_rmid_server_status,    only: [:new, :create, :edit, :update, :update_protocol_type]

  def new
    @protocol = params[:protocol_type].capitalize.constantize.new
    @protocol.populate_for_edit
    @protocol.setup_study_type_answers if @protocol.is_a?(Study)

    gon.rmid_api_url    = Setting.get_value("research_master_api")
    gon.rmid_api_token  = Setting.get_value("rmid_api_token")
  end

  def create
    @protocol = protocol_params[:type].capitalize.constantize.new(protocol_params)

    if @protocol.valid?
      unless @protocol.project_roles.map(&:identity_id).include? current_user.id
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save

      @service_request.update_attribute(:protocol, @protocol)
      @service_request.update_attribute(:status, 'draft')
      @service_request.sub_service_requests.update_all(status: 'draft')

      last_ssr_id = @service_request.sub_service_requests.sort_by(&:ssr_id).last.ssr_id.to_i

      @protocol.update_attribute(:next_ssr_id, last_ssr_id + 1)

      if Setting.get_value("use_epic") && @protocol.selected_for_epic
        @protocol.ensure_epic_user
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless Setting.get_value("queue_epic")
      end

      flash[:success] = I18n.t('protocols.created', protocol_type: @protocol.type)

      redirect_to protocol_service_request_path(srid: @service_request.id)
    else
      @errors = @protocol.errors
    end
  end

  def edit
    @protocol_type                          = @protocol.type
    @in_dashboard                           = false
    @protocol.populate_for_edit
    @protocol.valid?
    @errors = @protocol.errors
    gon.rmid_api_url = Setting.get_value("research_master_api")
    gon.rmid_api_token = Setting.get_value("rmid_api_token")

    respond_to do |format|
      format.html
    end
  end

  def update
    protocol_type = protocol_params[:type]
    @protocol = @protocol.becomes(protocol_type.constantize) unless protocol_type.nil?
    if protocol_type == 'Study' && @protocol.valid?
      @protocol.update_attribute(:type, protocol_type)
      @protocol.activate
      @protocol.reload
    end

    if @protocol.update_attributes(protocol_params.merge(study_type_question_group_id: StudyTypeQuestionGroup.active_id))
      flash[:success] = I18n.t('protocols.updated', protocol_type: @protocol.type)
    else
      @errors = @protocol.errors
    end

    if @service_request.status == 'first_draft'
      @service_request.update_attributes(status: 'draft')
      @service_request.sub_service_requests.update_all(status: 'draft')
    end
  end

  def update_protocol_type
    @protocol       = Protocol.find(params[:id])

    # Setting type and study_type_question_group, not actually saving
    @protocol.type  = params[:type]
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

  def show
    respond_to do |format|
      format.js
    end
  end

  def push_to_epic_status
    @protocol = Protocol.find params[:id]

    respond_to do |format|
      format.json {
        render(
            status: 200,
            json: {
              last_epic_push_time: @protocol.last_epic_push_time,
              last_epic_push_status: @protocol.last_epic_push_status,
              last_epic_push_status_text: EPIC_PUSH_STATUS_TEXT[@protocol.last_epic_push_status],
            })
      }
    end
  end

  def approve_epic_rights
    @protocol = Protocol.find params[:id]

    # Send a notification to the primary PI for final review before
    # pushing to epic.  The email will contain a link which calls
    # push_to_epic.
    @protocol.awaiting_final_review_for_epic_push
    send_epic_notification_for_final_review(@protocol)

    render :formats => [:html]
  end

  def push_to_epic
    @protocol = Protocol.find params[:id]
    epic_queue = EpicQueue.find params[:eq_id]
    epic_queue.update_attribute(:attempted_push, true)
    # removed 12/23/13 per request by Lane
    #if current_user != @protocol.primary_principal_investigator then
    #  raise ArgumentError, "User is not primary PI"
    #end

    # Do the final push to epic in a separate thread.  The page which is
    # rendered will
    push_protocol_to_epic(@protocol)
    epic_queue.destroy

    respond_to do |format|
      format.html
      format.js
    end
  end

  def get_study_type_note
    answers = params[:answers].values.map{ |a| ActiveModel::Type::Boolean.new.cast(a) }
    @note   = StudyTypeFinder.new(nil, answers).determine_study_type_note
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    # Fix identity_id nil problem when lazy loading is enabled
    # when lazy loadin is enabled, identity_id is merely ldap_uid, the identity may not exist in database yet, so we create it if necessary here
    if Setting.get_value("use_ldap") && Setting.get_value("lazy_load_ldap") && params[:primary_pi_role_attributes][:identity_id].present?
      params[:primary_pi_role_attributes][:identity_id] = Identity.find_or_create(params[:primary_pi_role_attributes][:identity_id]).id
    end

    # Sanitize date formats
    params[:funding_start_date]           = sanitize_date params[:funding_start_date]
    params[:potential_funding_start_date] = sanitize_date params[:potential_funding_start_date]
    params[:guarantor_phone]              = sanitize_phone params[:guarantor_phone]

    if params[:human_subjects_info_attributes]
      params[:human_subjects_info_attributes][:initial_irb_approval_date] = sanitize_date params[:human_subjects_info_attributes][:initial_irb_approval_date]
      params[:human_subjects_info_attributes][:irb_approval_date]         = sanitize_date params[:human_subjects_info_attributes][:irb_approval_date]
      params[:human_subjects_info_attributes][:irb_expiration_date]       = sanitize_date params[:human_subjects_info_attributes][:irb_expiration_date]
    end

    if params[:vertebrate_animals_info_attributes]
      params[:vertebrate_animals_info_attributes][:iacuc_approval_date]   = sanitize_date params[:vertebrate_animals_info_attributes][:iacuc_approval_date]
      params[:vertebrate_animals_info_attributes][:iacuc_expiration_date] = sanitize_date params[:vertebrate_animals_info_attributes][:iacuc_expiration_date]
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
      primary_pi_role_attributes: [:id, :identity_id, :role, :project_rights, :_destroy],
      research_types_info_attributes: [:id, :human_subjects, :vertebrate_animals, :investigational_products, :ip_patents],
      study_phase_ids: [],
      study_types_attributes: [:id, :name, :new, :position, :_destroy],
      study_type_answers_attributes: [:id, :answer, :study_type_question_id, :_destroy],
      vertebrate_animals_info_attributes: [:id, :iacuc_number, :name_of_iacuc, :iacuc_approval_date, :iacuc_expiration_date]
    )
  end

  def push_protocol_to_epic protocol
    # Run the push to epic call in a child thread, so that we can return
    # the confirmation page right away without blocking (in testing, the
    # push to epic can take as long as 20 seconds).  This call will
    # write the status to the database, which will later be polled by
    # the confirmation page.
    #
    # TODO: Ideally this would be better off done in another process,
    # e.g. with delayed_job or resque.  Multithreaded code can be tricky
    # to get right.  However, there is a bit of extra work involved in
    # starting a separate job server, and it is not clear how (or if it
    # is possible) to start the job server automatically.  Threads work
    # well enough for now.
    #
    # Thread.new do
    begin
      # Do the actual push.  This might take a while...
      protocol.push_to_epic(EPIC_INTERFACE, "overlord_push", current_user.id)
      errors = EPIC_INTERFACE.errors
      session[:errors] = errors unless errors.empty?
      @epic_errors = true unless errors.empty?

    rescue Exception => e
      # Log any errors, since they will not be caught by the main
      # thread
      Rails.logger.error(e)

      # ensure
      # The connection MUST be closed when the thread completes to
      # avoid leaking the connection.
      # ActiveRecord::Base.connection.close
    end
    # end
  end

  def convert_date_for_save(attrs, date_field)
    if attrs[date_field] && attrs[date_field].present?
      attrs[date_field] = Time.strptime(attrs[date_field], "%m/%d/%Y")
    end

    attrs
  end
end
