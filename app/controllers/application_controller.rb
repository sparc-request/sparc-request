class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user

  before_filter :setup_navigation

  def current_user
    current_identity
  end

  def prepare_catalog
    if session['sub_service_request_id']
      @institutions = @sub_service_request.organization.parents.select{|x| x.type == 'Institution'}
    else
      @institutions = Institution.order('`order`')
    end

    if USE_GOOGLE_CALENDAR
      curTime = Time.now
      startMin = curTime
      startMax  = (curTime + 7.days)

      cal = Google::Calendar.new(:username => GOOGLE_USERNAME,
                                 :password => GOOGLE_PASSWORD)
      events_list = cal.find_events_in_range(startMin, startMax)
      @events = []
      begin
        events_list.sort_by! { |event| event.start_time }
        events_list.each do |event|
          @events << create_calendar_event(event)
        end
      rescue
        if events_list
          @events << create_calendar_event(events_list)
        end
      end
    end

    if USE_NEWS_FEED
      page = Nokogiri::HTML(open("http://www.sparcrequestblog.com"))
      headers = page.css('.entry-header').take(3)
      @news = []
      headers.each do |header|
        @news << {:title => header.at_css('.entry-title').text,
                  :link => header.at_css('.entry-title a')[:href],
                  :date => header.at_css('.date').text }
      end
    end
  end
  
  def authorization_error msg, ref
    error = msg
    error += "<br />If you believe this is in error please contact, #{I18n.t 'error_contact'}, and provide the following information:"
    error += "<br /> Reference #: "
    error += ref
    render :partial => 'service_requests/authorization_error', :locals => {:error => error}
  end

  def clean_errors errors
    errors.to_a.map {|k,v| "#{k.humanize} #{v}".rstrip + '.'}
  end

  def clean_messages errors
    errors.map {|k,v| v}.flatten
  end

  # Initialize the instance variables used with service requests:
  #   @service_request
  #   @sub_service_request
  #   @line_items
  #
  # These variables are initialized from params (if set) or cookies.
  def initialize_service_request
    @service_request = nil
    @sub_service_request = nil
    @line_items = nil

    if params[:edit_original]
      # If editing the original service request, we delete the sub
      # service request id (remember, a sub service request is a service
      # request that has been split out).
      session.delete(:sub_service_request_id)
    end

    if params[:controller] == 'service_requests'
      if params[:action] == 'catalog' and params[:id].nil?
        # Catalog is the main service requests page; this is where the
        # service request is first created.  We will create the service
        # request in a moment.
        #
        # If the "go back" button is used, then params[:id] will be
        # non-nil, and we will not create a new service request.
        session.delete(:service_request_id)
        session.delete(:sub_service_request_id)
      else
        # For all other service request controller actions, we go ahead
        # and set the cookie.
        session[:service_request_id] = params[:id] if params[:id]
        session[:sub_service_request_id] = params[:sub_service_request_id] if params[:sub_service_request_id]
      end

      if session[:service_request_id]
        # If the cookie is non-nil, then lookup the service request.  If
        # the service request is not found, display an error.
        use_existing_service_request
        validate_existing_service_request
      else
        # If the cookie is nil (as with visiting the main catalog for
        # the first time), then create a new service request.
        create_new_service_request
      end
    elsif params[:controller] == 'devise/sessions'
      if session[:service_request_id]
        use_existing_service_request
      else
        @service_request = ServiceRequest.new :status => 'first_draft'
        @service_request.save :validate => false
        @line_items = []
        session[:service_request_id] = @service_request.id
      end
    else
      # For controllers other than the service requests controller, we
      # look up the service request, but do not display any errors.
      use_existing_service_request
    end
  end

  # Set @service_request, @sub_service_request, and @line_items from the
  # ids stored in the session.
  def use_existing_service_request
    @service_request = ServiceRequest.find session[:service_request_id]
    if session[:sub_service_request_id]
      @sub_service_request = @service_request.sub_service_requests.find session[:sub_service_request_id]
      @line_items = @sub_service_request.try(:line_items)
    else
      @line_items = @service_request.try(:line_items)
    end
  end

  # Validate @service_request and @sub_service_request (after having
  # been set by use_existing_service_request).  Renders an error page if
  # they were not found.
  def validate_existing_service_request
    if @service_request.nil?
      authorization_error "The service request you are trying to access can not be found.",
                          "SR#{params[:id]}"
    elsif session[:sub_service_request_id] and @sub_service_request.nil?
      authorization_error "The service request you are trying to access can not be found.", 
                          "SSR#{params[:sub_service_request_id]}"
    end
  end

  # Create a new service request and assign it to @service_request.
  def create_new_service_request
    @service_request = ServiceRequest.new :status => 'first_draft'
    if params[:protocol_id] # we want to create a new service request that belongs to an existing protocol
      if current_user and current_user.protocols.where(:id => params[:protocol_id]).empty? # this user doesn't have permission to create service request under this protocol
        authorization_error "You are attempting to create a service request under a study/project that you do not have permissions to access.",
                            "PROTOCOL#{params[:protocol_id]}"
      else # otherwise associate the service request with this protocol
        @service_request.protocol_id = params[:protocol_id]
      end
    end

    # if the user has requested an account and it is pending approval we need to change the login message
    signed_up_but_not_approved = false
    if flash[:notice] == I18n.t("devise.registrations.identity.signed_up_but_not_approved") # use the local version of the text
      signed_up_but_not_approved = true
    end

    @service_request.save :validate => false
    session[:service_request_id] = @service_request.id
    redirect_to catalog_service_request_path(@service_request, :signed_up_but_not_approved => signed_up_but_not_approved)
  end

  def authorize_identity
    # can the user edit the service request
    # can the user edit the sub service request
 
    # we have a current user
    if current_user
      if @sub_service_request.nil? and current_user.can_edit_request? @service_request
        return true
      elsif @sub_service_request and current_user.can_edit_request? @sub_service_request
        return true
      end

    # the service request is in first draft and has yet to be submitted (catalog page only)
    elsif @service_request.status == 'first_draft' and @service_request.service_requester_id.nil?
      return true
    elsif !@service_request.status.nil? # this is a previous service request so we should attempt to sign in
      authenticate_identity! 
      return true
    end
    
    if @sub_service_request.nil?
      authorization_error "The service request you are trying to access is not editable.",
                          "SR#{session[:service_request_id]}"
    else
      authorization_error "The service request you are trying to access is not editable.",
                          "SSR#{session[:sub_service_request_id]}"
    end
  end

  def setup_navigation
    #TODO - this could definitely be done a better way
    @page = if params[:action] == 'navigate'
        params[:current_location] || request.referrer.split('/').last.split('?').first
      else
        params[:action]
      end


    c = YAML.load_file(Rails.root.join('config', 'navigation.yml'))[@page]
    unless c.nil?
      @step_text = c['step_text']
      @css_class = c['css_class']
      @back = c['back']
      @catalog = c['catalog']
      @forward = c['forward']
      @validation_groups = c['validation_groups']
    end
  end
end
