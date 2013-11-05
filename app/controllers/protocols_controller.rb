class ProtocolsController < ApplicationController
  respond_to :json, :js, :html
  before_filter :initialize_service_request, :except => [:approve_epic_rights, :push_to_epic]
  before_filter :authorize_identity, :except => [:approve_epic_rights, :push_to_epic]
  before_filter :set_protocol_type, :except => [:approve_epic_rights, :push_to_epic]

  def new
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = self.model_class.new
    @protocol.requester_id = current_user.id
    @protocol.populate_for_edit
  end

  def create
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = self.model_class.new(params[:study] || params[:project])

    if @protocol.valid?
      @protocol.save
      session[:saved_protocol_id] = @protocol.id
      flash[:notice] = "New #{@protocol.type.downcase} created"
    else
      # TODO: Is this neccessary?
      @protocol.populate_for_edit
    end
  end

  def edit
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = current_user.protocols.find params[:id]
    @protocol.populate_for_edit
  end

  def update
    @service_request = ServiceRequest.find session[:service_request_id]
    @protocol = current_user.protocols.find params[:id]

    if @protocol.update_attributes(params[:study] || params[:project])
      session[:saved_protocol_id] = @protocol.id
      flash[:notice] = "#{@protocol.type.humanize} updated"
    end
      
    @protocol.populate_for_edit
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

    if current_user != @protocol.primary_principal_investigator then
      raise ArgumentError, "User is not primary PI"
    end

    # Do the final push to epic in a separate thread.  The page which is
    # rendered will
    push_protocol_to_epic(@protocol)

    render :formats => [:html]
  end

  private

  def send_epic_notification_for_final_review(protocol)
    Notifier.notify_primary_pi_for_epic_user_final_review(protocol).deliver
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
