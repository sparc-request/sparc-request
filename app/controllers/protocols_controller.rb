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
  include ProtocolsControllerShared

  before_action :initialize_service_request,  only: [:show, :new, :create, :edit, :update, :update_protocol_type]
  before_action :authorize_identity,          only: [:show, :new, :create, :edit, :update, :update_protocol_type]
  before_action :find_protocol,               only: [:show, :edit, :update]

  def show
    respond_to :js
  end

  def create
    @protocol = protocol_params[:type].capitalize.constantize.new(protocol_params)

    if @protocol.valid?
      # if current user is not authorized, add them as an authorized user
      unless @protocol.primary_pi_role.identity == current_user
        @protocol.project_roles.new(identity: current_user, role: 'general-access-user', project_rights: 'approve')
      end

      @protocol.next_ssr_id = @service_request.sub_service_requests.order(:ssr_id).last.ssr_id.to_i + 1
      @protocol.save
      @service_request.update_attribute(:protocol, @protocol)
      @service_request.update_status('draft', current_user)

      if Setting.get_value("use_epic") && @protocol.selected_for_epic
        @protocol.ensure_epic_user
        Notifier.notify_for_epic_user_approval(@protocol).deliver unless Setting.get_value("queue_epic")
      end

      flash[:success] = I18n.t('protocols.created', protocol_type: @protocol.type)
    else
      @errors = @protocol.errors
    end

    respond_to :js
  end

  def edit
    respond_to :html

    @protocol.populate_for_edit
    @protocol.valid?
    @errors = @protocol.errors
  end

  def update
    if @protocol.update_attributes(protocol_params)
      if @service_request.status == 'first_draft'
        @service_request.update_status('draft', current_user)
      end

      flash[:success] = I18n.t('protocols.updated', protocol_type: @protocol.type)
    else
      @errors = @protocol.errors
    end

    respond_to :js
  end

  def update_protocol_type
    @protocol                     = Protocol.find(params[:id]).becomes(params[:type].constantize)
    @protocol.type                = params[:type]
    @protocol.research_master_id  = nil   if @protocol.is_a?(Project)
    @protocol.rmid_validated      = false if @protocol.is_a?(Project)
    @protocol.save(validate: false)

    flash[:success] = t('protocols.change_type.updated')

    respond_to :js
  end

  def validate_rmid
    respond_to :js

    if protocol_params[:research_master_id]
      if params[:protocol_id].present?
        @protocol = Protocol.find(params[:protocol_id])
        @protocol.assign_attributes(protocol_params)
      else
        @protocol = Protocol.new(protocol_params)
      end
      @protocol.valid?
      @errors = @protocol.errors.messages[:base] + @protocol.errors.messages[:research_master_id]

      unless @errors.any?
        @rmid_record = Protocol.get_rmid(protocol_params[:research_master_id])
      end
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
end
