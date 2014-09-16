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

class ProtocolsController < ApplicationController
  respond_to :json, :js, :html
  before_filter :initialize_service_request, :except => [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :authorize_identity, :except => [:approve_epic_rights, :push_to_epic, :push_to_epic_status]
  before_filter :set_protocol_type, :except => [:approve_epic_rights, :push_to_epic, :push_to_epic_status]

  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @epic_services = @service_request.should_push_to_epic? if USE_EPIC
    @protocol = self.model_class.new
    @protocol.requester_id = current_user.id
    @protocol.populate_for_edit
    @current_step = 'protocol'
    @portal = false
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    @current_step = params[:current_step]
    @protocol = self.model_class.new(params[:study] || params[:project])
    @protocol.validate_nct = true
    @portal = params[:portal]

    if @current_step == 'go_back'
      @current_step = 'protocol'
      @protocol.populate_for_edit
    elsif @current_step == 'protocol' and @protocol.group_valid? :protocol
      @current_step = 'user_details'
      @protocol.populate_for_edit
      #setup human_subjects_info validation
      @protocol.valid?
    elsif @current_step == 'user_details' and @protocol.valid?
      @protocol.save
      @current_step = 'return_to_service_request'
      session[:saved_protocol_id] = @protocol.id
      flash[:notice] = "New #{@protocol.type.downcase} created"
    elsif @current_step == 'cancel_protocol'
      @current_step = 'return_to_service_request'
    else
      @protocol.populate_for_edit
    end
  end

  def edit
    @service_request = ServiceRequest.find session[:service_request_id]
    @epic_services = @service_request.should_push_to_epic? if USE_EPIC
    @protocol = current_user.protocols.find params[:id]
    @protocol.populate_for_edit
    @current_step = 'protocol'
    @portal = false
  end

  def update
    @service_request = ServiceRequest.find session[:service_request_id]
    @current_step = params[:current_step]
    @protocol = current_user.protocols.find params[:id]
    @protocol.validate_nct = true
    @portal = params[:portal]

    @protocol.assign_attributes(params[:study] || params[:project])

    if @current_step == 'protocol' and @protocol.group_valid? :protocol
      @current_step = 'user_details'
      @protocol.populate_for_edit
      #setup human_subjects_info validation
      @protocol.valid?
    elsif (@current_step == 'user_details' and @protocol.valid?)
      @protocol.save
      @current_step = 'return_to_service_request'
      session[:saved_protocol_id] = @protocol.id
      flash[:notice] = "#{@protocol.type.humanize} updated"
    else
      @protocol.populate_for_edit
    end
  end

  def destroy

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

  private

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
