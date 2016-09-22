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
  respond_to :json, :js, :html
  before_filter :initialize_service_request, unless: :from_portal?, :except => [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :authorize_identity, unless: :from_portal?, :except => [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :set_protocol_type, :except => [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :set_portal

  def new
    @protocol = self.model_class.new
    setup_protocol = SetupProtocol.new(params[:portal], @protocol, current_user, session[:service_request_id])
    setup_protocol.setup
    @epic_services = setup_protocol.set_epic_services
    set_cookies
    resolve_layout
  end

  def create

    unless from_portal?
      @service_request = ServiceRequest.find session[:service_request_id]
    end

    @current_step = cookies['current_step']

    new_protocol_attrs = params[:study] || params[:project] || Hash.new
    @protocol = self.model_class.new(new_protocol_attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first))

    @protocol.validate_nct = true

    if @current_step == 'cancel'
      @current_step = 'return_to_service_request'
    elsif @current_step == 'go_back'
      @current_step = 'protocol'
      @protocol.populate_for_edit
    elsif @current_step == 'protocol' and @protocol.group_valid? :protocol
      @current_step = 'user_details'
      @protocol.populate_for_edit
    elsif @current_step == 'user_details' and @protocol.valid?
      unless @protocol.project_roles.map(&:identity_id).include? current_user.id
        # if current user is not authorized, add them as an authorized user
        @protocol.project_roles.new(identity_id: current_user.id, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.save

      @current_step = 'return_to_service_request'

      if @service_request
        @service_request.update_attribute(:protocol_id, @protocol.id) unless @service_request.protocol.present?
        @service_request.update_attribute(:status, 'draft')
        @service_request.sub_service_requests.each do |ssr|
          ssr.update_attribute(:status, 'draft')
        end
        @service_request.ensure_ssr_ids
      end

      @current_step = 'return_to_service_request'
    else
      @protocol.populate_for_edit
    end

    cookies['current_step'] = @current_step

    if @current_step != 'return_to_service_request'
      resolve_layout
    end
  end

  def edit

    @service_request = ServiceRequest.find session[:service_request_id]
    @epic_services = @service_request.should_push_to_epic? if USE_EPIC
    @protocol = current_user.protocols.find params[:id]
    @protocol.populate_for_edit
    @protocol.valid?

    current_step_cookie = cookies['current_step']
    cookies['current_step'] = 'protocol'
  end

  def update
    @service_request = ServiceRequest.find session[:service_request_id]
    @current_step = cookies['current_step']
    @protocol = current_user.protocols.find params[:id]

    @protocol.validate_nct = true

    attrs = if @protocol.type.downcase.to_sym == :study && params[:study]
      params[:study]
    elsif @protocol.type.downcase.to_sym == :project && params[:project]
      params[:project]
    else
      Hash.new
    end

    @protocol.assign_attributes(attrs.merge(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first))

    if @current_step == 'cancel'
      @current_step = 'return_to_service_request'
    elsif @current_step == 'go_back' and @protocol.valid?
      @current_step = 'protocol'
      @protocol.populate_for_edit
    elsif @current_step == 'protocol' and @protocol.group_valid? :protocol
      @current_step = 'user_details'
      @protocol.populate_for_edit
    elsif @current_step == 'user_details' and @protocol.valid?
      @protocol.save
      @current_step = 'return_to_service_request'
      session[:saved_protocol_id] = @protocol.id

      #Added as a safety net for older SRs
      if @service_request.status == "first_draft"
        @service_request.update_attributes(status: "draft")
      end
    elsif @current_step == 'go_back' and !@protocol.valid?
      @current_step = 'user_details'
      @protocol.populate_for_edit
    else
      @protocol.populate_for_edit
    end
    cookies['current_step'] = @current_step
  end

  def set_protocol_type
    raise NotImplementedError
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
      protocol.push_to_epic(EPIC_INTERFACE)
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
end
