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

class ProtocolsController < ApplicationController

  respond_to :html, :js, :json

  before_filter :initialize_service_request,  unless: :from_portal?,  except: [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :authorize_identity,          unless: :from_portal?,  except: [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :set_portal
  before_filter :find_protocol,               only: [:edit, :update, :view_details]

  def new
    @protocol_type          = params[:protocol_type]
    @protocol               = @protocol_type.capitalize.constantize.new
    @protocol.requester_id  = current_user.id
    @service_request        = ServiceRequest.find(params[:srid])
    @protocol.populate_for_edit
  end

  def create
    protocol_class                          = params[:protocol][:type].capitalize.constantize
    attrs                                   = fix_date_params
    @protocol                               = protocol_class.new(attrs)
    @service_request                        = ServiceRequest.find(params[:srid])
    @protocol.study_type_question_group_id  = StudyTypeQuestionGroup.active_id if protocol_class == Study

    if @protocol.valid?
      unless @protocol.project_roles.map(&:identity_id).include? current_user.id
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save

      @service_request.update_attribute(:protocol, @protocol)
      @service_request.update_attribute(:status, 'draft')
      @service_request.sub_service_requests.update_all(status: 'draft')

      @protocol.update_attribute(:next_ssr_id, @service_request.sub_service_requests.count + 1)

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
    @protocol_type                          = @protocol.type
    @service_request                        = ServiceRequest.find(params[:srid])
    @in_dashboard                           = false
    @protocol.populate_for_edit
    @protocol.valid?
    @errors = @protocol.errors

    respond_to do |format|
      format.html
    end
  end

  def update

    if params[:updated_protocol_type] == 'true' && params[:protocol][:type] == 'Study'
      @protocol.update_attribute(:type, params[:protocol][:type])
      @protocol.activate
      @protocol = Protocol.find(params[:id]) #Protocol reload
    end

    attrs            = fix_date_params
    @service_request = ServiceRequest.find(params[:srid])

    if @protocol.update_attributes(attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active_id))
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
    @protocol.populate_for_edit
    
    flash[:success] = t(:protocols)[:change_type][:updated]
    if @protocol_type == "Study" && @protocol.sponsor_name.nil? && @protocol.selected_for_epic.nil?
      flash[:alert] = t(:protocols)[:change_type][:new_study_warning]
    end  
  end

  def view_details
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

    # removed 12/23/13 per request by Lane
    #if current_user != @protocol.primary_principal_investigator then
    #  raise ArgumentError, "User is not primary PI"
    #end

    # Do the final push to epic in a separate thread.  The page which is
    # rendered will
    push_protocol_to_epic(@protocol)

    render :formats => [:html]
  end

  def from_portal?
    return params[:portal] == "true"
  end

  private

  def find_protocol
    @protocol = Protocol.find(params[:id])
  end

  def resolve_layout
    if from_portal?
      @user = current_user
      render layout: "portal/application"
    end
  end

  def set_cookies
    current_step_cookie = cookies['current_step']
    cookies['current_step'] = 'protocol'
  end

  def set_portal
    # Where is this used? - Kyle Glick
    @portal = params[:portal]
  end

  def send_epic_notification_for_final_review(protocol)
    Notifier.notify_primary_pi_for_epic_user_final_review(protocol).deliver unless QUEUE_EPIC
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
      protocol.push_to_epic(EPIC_INTERFACE, "pi_email_approval", current_user.id)
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
